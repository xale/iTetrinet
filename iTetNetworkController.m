//
//  iTetNetworkController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import "iTetNetworkController.h"
#import "iTetWindowController.h"
#import "iTetPlayersController.h"
#import "iTetGameViewController.h"
#import "iTetChatViewController.h"
#import "iTetWinlistViewController.h"
#import "iTetPreferencesController.h"

#import "AsyncSocket.h"
#import "iTetServerInfo.h"

#import "iTetMessage+ClassFactory.h"
#import "iTetIncomingMessages.h"
#import "iTetOutgoingMessages.h"

#import "iTetLocalPlayer.h"

#import "NSData+SingleByte.h"
#import "NSData+Searching.h"

NSString* const iTetNetworkErrorDomain = @"iTetNetworkError";
#define iTetNetworkPort					(31457)
#define iTetNetworkTerminatorCharacter	(0xFF)

@interface iTetNetworkController (Private)

- (void)messageReceived:(iTetMessage<iTetIncomingMessage>*)message;
- (void)handleError:(NSError*)error;

- (void)setConnectionState:(iTetConnectionState)newState;

@end


@implementation iTetNetworkController

- (id)init
{
	connectionSocket = [[AsyncSocket alloc] initWithDelegate:self];
	
	return self;
}

- (void)dealloc
{
	// Disconnect
	[self disconnect];
	
	// Release socket and server data
	[connectionSocket release];
	[currentServer release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)openCloseConnection:(id)sender
{
	switch ([self connectionState])
	{
		// If there is already a connection open, disconnect
		case connected:
		{
			// If local player is playing a game, ask the user before disconnecting
			if ([[playersController localPlayer] isPlaying])
			{
				// Create an alert
				NSAlert* alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:@"Game in Progress"];
				[alert setInformativeText:@"A game is currently in progress. Are you sure you want to disconnect from the server?"];
				[alert addButtonWithTitle:@"Disconnect"];
				[alert addButtonWithTitle:@"Continue Playing"];
				
				// Run the alert as a sheet
				[alert beginSheetModalForWindow:[windowController window]
								  modalDelegate:self
								 didEndSelector:@selector(disconnectWithGameInProgressAlertDidEnd:returnCode:contextInfo:)
									contextInfo:NULL];
				
				return;
			}
			
			// Otherwise, just disconnect from the server
			[self disconnect];
			
			return;
		}
		
		// If we are attempting to open a connection, abort the attempt
		case connecting:
		{
			// Abort connection
			[self disconnect];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:@"Connection canceled"];
			
			return;
		}
		
		// If we are not connected, open the server list for a new connection
		case disconnected:
		{
			// Create an alert for the server selection dialog
			NSAlert* dialog = [[[NSAlert alloc] init] autorelease];
			[dialog setMessageText:@"Connect to Server"];
			[dialog setInformativeText:@"Select a server to connect to:"];
			[dialog addButtonWithTitle:@"Connect"];
			[dialog addButtonWithTitle:@"Cancel"];
			[dialog addButtonWithTitle:@"Edit Server List..."];
			
			// Add the server selection view as the dialog's accessory
			[dialog setAccessoryView:serverListView];
			
			// Run the dialog as a sheet
			[dialog beginSheetModalForWindow:[windowController window]
							   modalDelegate:self
							  didEndSelector:@selector(connectAlertDidEnd:returnCode:contextInfo:)
								 contextInfo:NULL];
		}
	}
}

- (void)connectAlertDidEnd:(NSAlert*)dialog
				returnCode:(NSInteger)returnCode
			   contextInfo:(void*)contextInfo
{
	// If the user cancelled, do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// If the user clicked "edit server list" open the preferences window
	if (returnCode == NSAlertThirdButtonReturn)
	{
		[[dialog window] orderOut:self];
		[windowController openServersPreferencesTab:self];
		return;
	}
	
	// Determine the server the user wishes to connect to
	iTetServerInfo* server = [[serverListController selectedObjects] objectAtIndex:0];
	
	// Order out the dialog
	[[dialog window] orderOut:self];
	
	// Attempt to connect to the server
	[self connectToServer:server];
}

- (void)disconnectWithGameInProgressAlertDidEnd:(NSAlert*)alert
									 returnCode:(NSInteger)returnCode
									contextInfo:(void*)contextInfo
{
	// If the user pressed "continue playing", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// Otherwise, tell the game controller that the game is over
	// (Do not tell the server to end game, so other players can keep playing)
	[gameController endGame];
	
	// Disconnect from the server
	[self disconnect];
}

#pragma mark -
#pragma mark Connecting

NSString* const iTetServerConnectionInfoFormat = @"Connecting to server %@...";

- (void)connectToServer:(iTetServerInfo*)server
{
	// Change the connection status label
	[connectionStatusLabel setStringValue:[NSString stringWithFormat:iTetServerConnectionInfoFormat, [server address]]];
	
	// Change the connection state
	[self setConnectionState:connecting];
	
	// Retain the server info
	currentServer = [server retain];
	
	// Attempt to open a connection to the server
	NSError* error;
	BOOL connectionSuccessful = [connectionSocket connectToHost:[currentServer address]
														 onPort:iTetNetworkPort
														  error:&error];
	
	// If the connection fails, determine the error
	if (!connectionSuccessful)
	{
		[self setConnectionState:disconnected];
		[self handleError:error];
	}
}

- (void)onSocket:(AsyncSocket*)socket
didConnectToHost:(NSString*)hostname
			port:(UInt16)port
{
	// FIXME: oh god the brokens
	if ([hostname isEqualToString:@"::1"])
		hostname = @"127.0.0.1";
	
	// Create and send the server login message
	[self sendMessage:[iTetLoginMessage messageWithProtocol:[[self currentServer] protocol]
												   nickname:[[self currentServer] nickname]
													address:hostname]];
	
	// Change the connection status label
	[connectionStatusLabel setStringValue:@"Logging in..."];
	
	// Clear the chat views
	[chatController clearChat];
	[chatController appendStatusMessage:@"Connection Opened"];
	[gameController clearChat];
	
	// Start reading data
	[connectionSocket readDataToData:[NSData dataWithByte:iTetNetworkTerminatorCharacter]
						 withTimeout:-1
								 tag:0];
}

#pragma mark -
#pragma mark Disconnecting

- (void)disconnect
{
	// If we are already disconnected, ignore
	if (![connectionSocket isConnected])
		return;
	
	// Tell the sockect to disconnect
	[connectionSocket disconnectAfterWriting];
}

- (void)onSocket:(AsyncSocket*)socket
willDisconnectWithError:(NSError*)error
{
	// If there is a game in progress, end it
	if ([gameController gameplayState] != gameNotPlaying)
		[gameController endGame];
	
	// If an error occurred, handle as appropriate
	if (error != nil)
		[self handleError:error];
}

- (void)onSocketDidDisconnect:(AsyncSocket*)socket
{
	// Change our connection state
	[self setConnectionState:disconnected];
	
	// Remove all players from the players controller
	[playersController removeAllPlayers];
	
	// Change the connection status label
	[connectionStatusLabel setStringValue:@"Disconnected"];
	
	// Append a status message on the chat view
	[chatController appendStatusMessage:@"Connection Closed"];
}

#pragma mark -
#pragma mark Reads/Writes

- (void)sendMessage:(iTetMessage<iTetOutgoingMessage>*)message
{
	// FIXME: debug logging
	NSData* messageData = [message rawMessageData];
	NSMutableString* debugString = [NSMutableString string];
	char byte;
	for (NSUInteger i = 0; i < [messageData length]; i++)
	{
		byte = ((char*)[messageData bytes])[i];
		if (byte > 31)
			[debugString appendFormat:@"%c", byte];
		else
			[debugString appendFormat:@"<\\%02d>", byte];
	}
	NSLog(@"DEBUG:    sending outgoing message: '%@'", debugString);
	
	// Append the delimiter byte and send the message
	[connectionSocket writeData:[messageData dataByAppendingByte:iTetNetworkTerminatorCharacter]
					withTimeout:-1
							tag:0];
}

- (void)onSocket:(AsyncSocket*)socket
	 didReadData:(NSData*)data
		 withTag:(long)tag
{
	// Convert the data to a message, after trimming the delimiter byte
	iTetMessage<iTetIncomingMessage>* message = [iTetMessage messageFromData:[data subdataToIndex:([data length] - 1)]];
	
	// Hand off the message for processing
	[self messageReceived:message];
	
	// Continue reading data
	[connectionSocket readDataToData:[NSData dataWithByte:iTetNetworkTerminatorCharacter]
						 withTimeout:-1
								 tag:0];
}

- (void)messageReceived:(iTetMessage<iTetIncomingMessage>*)message
{
	// Determine the nature of the message
	iTetMessageType type = [message messageType];
	switch (type)
	{
#pragma mark No Connecting (Error) Message
		case noConnectingMessage:
		{
			// Create an error
			NSDictionary* info = [NSDictionary dictionaryWithObject:[(iTetNoConnectingMessage*)message reason]
															 forKey:@"errorMessage"];
			NSError* error = [NSError errorWithDomain:iTetNetworkErrorDomain
												 code:iTetNoConnectingError
											 userInfo:info];
			
			// Pass the error to our own error-handling method
			[self handleError:error];
			break;
		}
			
#pragma mark Server Heartbeat
		case heartbeatMessage:
			// Send a keepalive message
			[self sendMessage:[iTetHeartbeatMessage message]];
			break;
			
#pragma mark Client Info Request
		case clientInfoRequestMessage:
			// Send client info to server
			[self sendMessage:[iTetClientInfoReplyMessage message]];
			break;
			
#pragma mark Player Number Message
		case playerNumberMessage:
			// Set the local player's number
			[playersController setLocalPlayerNumber:[(iTetPlayerNumberMessage*)message playerNumber]
										   nickname:[currentServer nickname]
										   teamName:[currentServer playerTeam]];
			
			[self sendMessage:[iTetPlayerTeamMessage messageForPlayer:[playersController localPlayer]]];
			
			// Change the connection state
			[self setConnectionState:connected];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:@"Connected"];
			
			break;
			
#pragma mark Player Join Message
		case playerJoinMessage:
		{
			iTetPlayerJoinMessage* joinMessage = (iTetPlayerJoinMessage*)message;
			
			// Check that this isn't an echo of our own join event
			if ([joinMessage playerNumber] == [[playersController localPlayer] playerNumber])
				break;
			
			// Add a new player with the specified name and number
			[playersController addPlayerWithNumber:[joinMessage playerNumber]
										  nickname:[joinMessage nickname]];
			
			// Add a status message to the chat view
			[chatController appendStatusMessage:[NSString stringWithFormat:@"Player %@ has joined the channel", [joinMessage nickname]]];
			break;
		}
			
#pragma mark Player Leave Message
		case playerLeaveMessage:
		{
			// Get player number
			NSInteger playerNum = [(iTetPlayerLeaveMessage*)message playerNumber];
			
			// If the player number is not the local player's, add a status message to the chat view
			if (playerNum != [[playersController localPlayer] playerNumber])
				[chatController appendStatusMessage:[NSString stringWithFormat:@"Player %@ has left the channel", [playersController playerNameForNumber:playerNum]]];
			
			// Remove the player from the game
			[playersController removePlayerNumber:playerNum];
			break;
		}
			
#pragma mark Player Team Message
		case playerTeamMessage:
		{
			// Change the specified player's team name
			iTetPlayerTeamMessage* teamMessage = (iTetPlayerTeamMessage*)message;
			[playersController setTeamName:[teamMessage teamName]
						   forPlayerNumber:[teamMessage playerNumber]];
			break;
		}
			
#pragma mark Winlist Message
		case winlistMessage:
			// Pass the winlist entries to the winlist controller
			[winlistController parseWinlist:[(iTetWinlistMessage*)message winlistTokens]];
			break;
			
#pragma mark Partyline Messages
		case plineChatMessage:
		case plineActionMessage:
		{
			// Add the message to the chat controller
			iTetPlineChatMessage* plineMessage = (iTetPlineChatMessage*)message;
			[chatController appendChatLine:[plineMessage messageContents]
							fromPlayerName:[playersController playerNameForNumber:[plineMessage senderNumber]]
									action:(type == plineActionMessage)];
			break;
		}
			
#pragma mark Game Chat Message
		case gameChatMessage:
		{
			// Check if the first space-delimited word of the message is or contains a player's name
			iTetGameChatMessage* chatMessage = (iTetGameChatMessage*)message;
			for (iTetPlayer* player in [playersController playerList])
			{
				if ([[chatMessage firstWord] rangeOfString:[player nickname]].location != NSNotFound)
				{
					// Add the message to the game chat view
					[gameController appendChatLine:[chatMessage contentsAfterFirstWord]
									fromPlayerName:[player nickname]];
					goto playerfound;
				}
			}
			
			// Otherwise, just dump the message on the game chat view
			[gameController appendChatLine:[chatMessage messageContents]];
			
		playerfound:
			break;
		}
			
#pragma mark New Game Message
		case newGameMessage:
			// Switch to the game view tab, if not already there
			[windowController switchToGameTab:self];
			
			// Tell the gameController to start the game
			[gameController newGameWithPlayers:[playersController playerList]
									 rulesList:[(iTetNewGameMessage*)message rulesList]
									  onServer:[self currentServer]];
			
			break;
			
#pragma mark Server In-Game Message
		case inGameMessage:
			// Set all players except the local player to "playing"
			[playersController setAllRemotePlayersToPlaying];
			
			// Set the game view controller's state as "playing"
			[gameController setGameplayState:gamePlaying];
			
			// Tell the game view controller to send the local player's field to the server
			[gameController sendFieldstring];
			
			break;
			
#pragma mark Pause/Resume Game Message
		case pauseResumeGameMessage:
		{
			// Get pause state
			BOOL pauseGame = [(iTetPauseResumeGameMessage*)message pauseGame];
			
			// Pause or resume the game
			if (pauseGame && ([gameController gameplayState] == gamePlaying))
			{
				// Pause the game
				[gameController pauseGame];
			}
			else if (!pauseGame && ([gameController gameplayState] == gamePaused))
			{
				// Make sure we have the game tab open
				[windowController switchToGameTab:self];
				
				// Resume the game
				[gameController resumeGame];
			}
			
			break;
		}
			
#pragma mark End of Game Message
		case endGameMessage:
			// End the game
			[gameController endGame];
			
			// If the user wants us to, automatically switch to the chat tab
			if ([[iTetPreferencesController preferencesController] autoSwitchChat])
				[windowController switchToChatTab:self];
			
			break;
			
#pragma mark Fieldstring Message
		case fieldstringMessage:
		{
			// Pass to the game controller
			iTetFieldstringMessage* fieldMessage = (iTetFieldstringMessage*)message;
			[gameController fieldstringReceived:[fieldMessage fieldstring]
									  forPlayer:[playersController playerNumber:[fieldMessage playerNumber]]
								  partialUpdate:[fieldMessage isPartialUpdate]];
			break;
		}
			
#pragma mark Level Update Message
		case levelUpdateMessage:
		{
			// Update the specified player's level
			iTetLevelUpdateMessage* levelMessage = (iTetLevelUpdateMessage*)message;
			[[playersController playerNumber:[levelMessage playerNumber]] setLevel:[levelMessage level]];
			break;
		}
			
#pragma mark Special Used/Lines Received Message
		case specialMessage:
		{
			// Translate player numbers into players
			iTetSpecialMessage* spMessage = (iTetSpecialMessage*)message;
			iTetPlayer* sender = nil;
			iTetPlayer* target = nil;
			if ([spMessage senderNumber] > 0)
				sender = [playersController playerNumber:[spMessage senderNumber]];
			if ([spMessage targetNumber] > 0)
				target = [playersController playerNumber:[spMessage targetNumber]];
			
			// Pass to game controller
			[gameController specialUsed:[spMessage specialType]
							   byPlayer:sender
							   onPlayer:target];
			break;
		}
			
#pragma mark Player Lost Message
		case playerLostMessage:
			// Set the player to "not playing"
			[playersController setPlayerIsPlaying:NO
								  forPlayerNumber:[(iTetPlayerLostMessage*)message playerNumber]];
			
			// FIXME: anything else?
			break;
			
#pragma mark Player Won Message
		case playerWonMessage:
			// FIXME: should this do anything?
			break;
			
		default:
			NSLog(@"WARNING: invalid message type in appController messageReceived: %d", type);
			break;
	}
}

#pragma mark -
#pragma mark Errors

- (void)handleError:(NSError*)error
{
	// Create an alert
	NSAlert* alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Error connecting to server"];
	
	// Determine the type of error
	NSMutableString* errorText = [NSMutableString string];
	if ([[error domain] isEqualToString:NSPOSIXErrorDomain])
	{
		switch ([error code])
		{
			case ECONNREFUSED:
				[errorText appendString:@"Connection refused. Check the server address and try again."];
				break;
			case EHOSTUNREACH:
				[errorText appendString:@"Could not find the specified server. Check the server address and try again."];
				break;
			default:
				[errorText appendString:@"A network error occurred:\n"];
				[errorText appendString:[error localizedDescription]];
				break;
		}
	}
	else if ([[error domain] isEqualToString:iTetNetworkErrorDomain])
	{
		switch ([error code])
		{
			case iTetNoConnectingError:
				[errorText appendString:@"Server login failed. Reason:\n"];
				[errorText appendString:[[error userInfo] objectForKey:@"errorMessage"]];
				break;
			default:
				[errorText appendString:@"An unknown error occurred.\n"];
				[errorText appendString:@"Error domain: iTetNetworkErrorDomain\n"];
				[errorText appendFormat:@"Error code: %d", [error code]];
				break;
		}
	}
	else
	{
		[errorText appendString:@"An unknown error occurred.\n"];
		[errorText appendFormat:@"Error domain: %@\n", [error domain]];
		[errorText appendFormat:@"Error code: %d", [error code]];
	}
	
	// Add the error information to the alert, along with an "Okay" button
	[alert setInformativeText:errorText];
	[alert addButtonWithTitle:@"Okay"];
	
	// Run the error as a sheet
	[alert beginSheetModalForWindow:[windowController window]
					  modalDelegate:self
					 didEndSelector:@selector(connectionErrorAlertEnded:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)connectionErrorAlertEnded:(NSAlert*)alert
					   returnCode:(NSInteger)returnCode
					  contextInfo:(void*)contextInfo
{
	// Does nothing
}

#pragma mark -
#pragma mark Accessors

@synthesize currentServer;

- (void)setConnectionState:(iTetConnectionState)newState
{
	if (connectionState == newState)
		return;
	
	switch (newState)
	{
		case disconnected:
			// Reset the connection toolbar item
			[connectionButton setLabel:@"Connect"];
			[connectionButton setImage:[NSImage imageNamed:@"Network"]];
			
			// Reset the connection menu item
			[connectionMenuItem setTitle:@"Connect to Server..."];
			[connectionMenuItem setKeyEquivalent:@"o"];
			
			// If we were attempting to connect, stop and hide the progress indicator
			if (connectionState == connecting)
			{
				[connectionProgressIndicator stopAnimation:self];
				[connectionProgressIndicator setHidden:YES];
			}
			
			break;
			
		case connecting:
			// Change the connection toolbar and menu items to "abort" actions
			[connectionButton setLabel:@"Cancel Connection"];
			[connectionButton setImage:[NSImage imageNamed:@"Cancel Red Button"]];
			[connectionMenuItem setTitle:@"Cancel Connection in Progress"];
			[connectionMenuItem setKeyEquivalent:@"w"];
			
			// Reveal and start the progress indicator
			[connectionProgressIndicator setHidden:NO];
			[connectionProgressIndicator startAnimation:self];
			
			break;
			
		case connected:
			// Stop and hide the progress indicator
			[connectionProgressIndicator stopAnimation:self];
			[connectionProgressIndicator setHidden:YES];
			
			// Change the connection toolbar and menu items to "disconnect" actions
			[connectionButton setLabel:@"Disconnect"];
			[connectionButton setImage:[NSImage imageNamed:@"Eject Blue Button"]];
			[connectionMenuItem setTitle:@"Disconnect from Server"];
			[connectionMenuItem setKeyEquivalent:@"w"];
			
			break;
	}
	
	connectionState = newState;
}
@synthesize connectionState;

@end
