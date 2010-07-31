//
//  iTetNetworkController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNetworkController.h"
#import "iTetWindowController.h"
#import "iTetPlayersController.h"
#import "iTetGameViewController.h"
#import "iTetChatViewController.h"
#import "iTetChannelsViewController.h"
#import "iTetWinlistViewController.h"
#import "iTetUserDefaults.h"

#import "AsyncSocket.h"
#import "iTetServerInfo.h"

#import "iTetMessage.h"

#import "iTetLocalPlayer.h"

#import "iTetGameRules.h"

#import "NSData+SingleByte.h"
#import "NSData+Subdata.h"
#import "NSDictionary+AdditionalTypes.h"

#import "iTetCommonLocalizations.h"

#ifdef _ITETRINET_DEBUG
#import "NSString+MessageData.h"
#import "iTetTextAttributes.h"
#endif

NSString* const iTetNetworkErrorDomain = @"iTetNetworkError";
#define iTetNetworkTerminatorCharacter	(0xFF)
#define iTetGameNetworkPort				(31457)

@interface iTetNetworkController (Private)

- (void)openServerSelectionDialog;

- (void)messageReceived:(iTetMessage*)message;
- (void)handleError:(NSError*)error;

- (void)setConnectionState:(iTetConnectionState)newState;

@end

@implementation iTetNetworkController

+ (void)initialize
{
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSNumber numberWithDouble:5.0]
				 forKey:iTetConnectionTimeoutPrefKey];
	[defaults setObject:[NSNumber numberWithBool:YES]
				 forKey:iTetAutoSwitchChatOnConnectPrefKey];
	[defaults setObject:[NSNumber numberWithBool:YES]
				 forKey:iTetAutoSwitchChatAfterGamePrefKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[iTetServerInfo defaultServers]]
				 forKey:iTetServersListPrefKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)init
{
	gameSocket = [[AsyncSocket alloc] initWithDelegate:self];
	
	return self;
}

- (void)dealloc
{
	// Disconnect
	[self disconnect];
	
	// Release socket and server data
	[gameSocket release];
	[currentServer release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

#define iTetDisconnectWithGameInProgressAlertInformativeText	NSLocalizedStringFromTable(@"A game is currently in progress. Are you sure you want to disconnect from the server?", @"NetworkController", @"Informative text on alert displayed when the user attempts to disconnect from a server while participating in a game")
#define iTetDisconnectWithGameInProgressConfirmButtonTitle		NSLocalizedStringFromTable(@"Forfeit and Disconnect", @"NetworkController", @"Title of button on 'disconnect with game in progress?' alert that allows the user to stop playing and disconnect")

#define iTetConnectWithOfflineGameInProgressAlertInformativeText	NSLocalizedStringFromTable(@"An offline game is currently in progress. Before you can connect to a server, you will have to forfeit the game. Are you sure you want to do this?", @"NetworkController", @"Informative text on alert displayed when the user attempts to open a new server connection while playing an offline game")
#define iTetConnectWithOfflineGameInProgressConfirmButtonTitle		NSLocalizedStringFromTable(@"Forfeit Game", @"NetworkController", @"Title of button on 'connect with offline game in progress?' alert that allows the user to stop playing the offline game and open a connection to a server")

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
				[alert setMessageText:iTetGameInProgressAlertTitle];
				[alert setInformativeText:iTetDisconnectWithGameInProgressAlertInformativeText];
				[alert addButtonWithTitle:iTetDisconnectWithGameInProgressConfirmButtonTitle];
				[alert addButtonWithTitle:iTetContinuePlayingButtonTitle];
				
				// Run the alert as a sheet
				[alert beginSheetModalForWindow:[windowController window]
								  modalDelegate:self
								 didEndSelector:@selector(disconnectWithGameInProgressAlertDidEnd:returnCode:contextInfo:)
									contextInfo:NULL];
				
				break;
			}
			
			// Otherwise, just disconnect from the server
			[self disconnect];
			
			break;
		}
			
			// If we are attempting to open a connection, abort the attempt
		case connecting:
		case login:
		{
			// Change connection state
			[self setConnectionState:canceled];
			
			// Abort connection
			[self disconnect];
			
			break;
		}
			
			// If we are not connected, open the server list for a new connection
		case disconnected:
		{
			// Check if the user is playing an offline game
			if ([gameController gameInProgress])
			{
				// Make note if the game was paused, pause if not
				BOOL gameWasPaused = ([gameController gameplayState] == gamePaused);
				if (!gameWasPaused)
					[gameController pauseGame];
				
				// If the user is playing an offline game, create an alert asking to end the game before connecting
				NSAlert* alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:iTetGameInProgressAlertTitle];
				[alert setInformativeText:iTetConnectWithOfflineGameInProgressAlertInformativeText];
				[alert addButtonWithTitle:iTetConnectWithOfflineGameInProgressConfirmButtonTitle];
				[alert addButtonWithTitle:iTetContinuePlayingButtonTitle];
				
				// Run the alert as sheet
				[alert beginSheetModalForWindow:[windowController window]
								  modalDelegate:self
								 didEndSelector:@selector(connectWithOfflineGameInProgressAlertDidEnd:returnCode:gameWasPaused:)
									contextInfo:[[NSNumber alloc] initWithBool:gameWasPaused]];
			}
			else
			{
				// If there is no offline game in progress, open the server selection dialog
				[self openServerSelectionDialog];
			}
			
			break;
		}
			
		case canceled:
		case connectionError:
		case disconnecting:
			NSAssert1(NO, @"NetworkController -openCloseConnection: called with invalid connection state: %d", [self connectionState]);
			break;
	}
}

- (void)disconnectWithGameInProgressAlertDidEnd:(NSAlert*)alert
									 returnCode:(NSInteger)returnCode
									contextInfo:(void*)contextInfo
{
	// If the user pressed "continue playing", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// Disconnect from the server
	[self disconnect];
}

- (void)connectWithOfflineGameInProgressAlertDidEnd:(NSAlert*)alert
										 returnCode:(NSInteger)returnCode
									  gameWasPaused:(NSNumber*)pauseState
{
	BOOL gameWasPaused = [pauseState boolValue];
	[pauseState release];
	
	// Order out the sheet
	[[alert window] orderOut:self];
	
	// If the user pressed "continue playing", resume the game
	if (returnCode == NSAlertSecondButtonReturn)
	{
		// If the game was not paused beforehand, resume the game
		if (!gameWasPaused)
			[gameController resumeGame];
		
		return;
	}
	
	// Otherwise, tell the game controller to end the game
	[gameController endGame];
	
	// Open the "connect to server" dialog
	[self openServerSelectionDialog];
}

#define iTetConnectToServerAlertTitle			NSLocalizedStringFromTable(@"Connect to Server", @"NetworkController", @"Title of 'connect to server' alert dialog")
#define iTetConnectToServerAlertInformativeText	NSLocalizedStringFromTable(@"Select a server to connect to:", @"NetworkController", @"Informative text on 'connect to server' alert dialog, prompting the user to select a server to connect to")
#define iTetConnectButtonTitle					NSLocalizedStringFromTable(@"Connect", @"NetworkController", @"Title of button or toolbar button used to open a connection to a server")
#define iTetEditServerListButtonTitle			NSLocalizedStringFromTable(@"Edit Server List...", @"NetworkController", @"Button on 'connect to server' alert dialog that cancels the connection and opens the preferences window to allow the user to edit the list of servers")

- (void)openServerSelectionDialog
{
	// Create an alert for the server selection dialog
	NSAlert* dialog = [[[NSAlert alloc] init] autorelease];
	[dialog setMessageText:iTetConnectToServerAlertTitle];
	[dialog setInformativeText:iTetConnectToServerAlertInformativeText];
	[dialog addButtonWithTitle:iTetConnectButtonTitle];
	[dialog addButtonWithTitle:iTetCancelButtonTitle];
	[dialog addButtonWithTitle:iTetEditServerListButtonTitle];
	
	// Add the table view containing the server list as the dialog's accessory
	[dialog setAccessoryView:serverListView];
	
	// Run the dialog as a sheet
	[dialog beginSheetModalForWindow:[windowController window]
					   modalDelegate:self
					  didEndSelector:@selector(connectAlertDidEnd:returnCode:contextInfo:)
						 contextInfo:NULL];
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

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Determine the element's action
	SEL action = [item action];
	
	if (action == @selector(openCloseConnection:))
	{
		switch ([self connectionState])
		{
			case canceled:
			case connectionError:
			case disconnecting:
				return NO;
				
			default:
				break;
		}
	}
	
	return YES;
}

#pragma mark -
#pragma mark Connecting

- (void)connectToServer:(iTetServerInfo*)server
{
	// Retain the server info
	currentServer = [server retain];
	
	// Change the connection state
	[self setConnectionState:connecting];
	
	// Attempt to open a connection to the server
	NSError* error;
	BOOL connectionSuccessful = [gameSocket connectToHost:[currentServer serverAddress]
												   onPort:iTetGameNetworkPort
													error:&error];
	
	// If the connection fails, determine the error
	if (!connectionSuccessful)
	{
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
	
	// Create a server login message
	iTetMessage* message;
	if ([currentServer protocol] == tetrinetProtocol)
		message = [iTetMessage messageWithMessageType:tetrinetLoginMessage];
	else
		message = [iTetMessage messageWithMessageType:tetrifastLoginMessage];
	[[message contents] setObject:[currentServer playerNickname]
						   forKey:iTetMessagePlayerNicknameKey];
	[[message contents] setObject:hostname
						   forKey:iTetMessageServerAddressKey];
	[[message contents] setInt:[currentServer gameVersion]
						forKey:iTetMessageGameVersionKey];
	
	// Send the login message
	[self sendMessage:message];
	
	// Change the connection state
	[self setConnectionState:login];
	
	// Start reading data
	[gameSocket readDataToData:[NSData dataWithByte:iTetNetworkTerminatorCharacter]
				   withTimeout:-1
						   tag:0];
}

#pragma mark -
#pragma mark Disconnecting

- (void)disconnect
{
	// If we are already disconnected, ignore
	if (![gameSocket isConnected])
		return;
	
	// If there is a game in progress, end it
	if ([gameController gameInProgress])
		[gameController endGame];
	
	// Change connection status, if necessary
	if ([self connectionOpen])
		[self setConnectionState:disconnecting];
	
	// Tell the socket to disconnect
	[gameSocket disconnectAfterWriting];
}

- (void)onSocket:(AsyncSocket*)socket
willDisconnectWithError:(NSError*)error
{
	// If there is a game in progress, end it
	if ([gameController gameInProgress])
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
	
	// Tell the channels view controller to stop updating the channel list
	[channelsController stopQueriesAndDisconnect];
}

#pragma mark -
#pragma mark Reads/Writes

- (void)sendMessage:(iTetMessage*)message
{
#ifdef _ITETRINET_DEBUG
	NSString* messageString = [NSString stringWithMessageData:[message rawMessageData]];
	NSMutableString* debugString = [NSMutableString string];
	unichar character;
	for (NSUInteger i = 0; i < [messageString length]; i++)
	{
		character = [messageString characterAtIndex:i];
		if ([[iTetTextAttributes chatTextAttributeCharacterSet] characterIsMember:character])
			[debugString appendFormat:@"<\\%02u>", (int)character];
		else
			[debugString appendFormat:@"%C", character];
	}
	NSLog(@"DEBUG:    sending outgoing message: '%@'", debugString);
#endif
	
	// Append the delimiter byte and send the message
	[gameSocket writeData:[[message rawMessageData] dataByAppendingByte:iTetNetworkTerminatorCharacter]
			  withTimeout:-1
					  tag:0];
}

- (void)onSocket:(AsyncSocket*)socket
	 didReadData:(NSData*)data
		 withTag:(long)tag
{
#ifdef _ITETRINET_DEBUG
	NSString* messageContents = [NSString stringWithMessageData:[data subdataToIndex:([data length] - 1)]];
	NSMutableString* debugString = [NSMutableString string];
	unichar character;
	for (NSUInteger i = 0; i < [messageContents length]; i++)
	{
		character = [messageContents characterAtIndex:i];
		if ([[iTetTextAttributes chatTextAttributeCharacterSet] characterIsMember:character])
			[debugString appendFormat:@"<\\%02u>", character];
		else
			[debugString appendFormat:@"%C", character];
	}
	NSLog(@"DEBUG:   received incoming message: '%@'", debugString);
#endif
	
	// Convert the data to a message, after trimming the delimiter byte
	iTetMessage* message = [iTetMessage messageWithMessageData:[data subdataToIndex:([data length] - 1)]];
	
	// Hand off the message for processing
	[self messageReceived:message];
	
	// Continue reading data
	[gameSocket readDataToData:[NSData dataWithByte:iTetNetworkTerminatorCharacter]
				   withTimeout:-1
						   tag:0];
}

#define iTetPlayerJoinedEventStatusMessageFormat	NSLocalizedStringFromTable(@"%@ has joined the channel", @"NetworkController", @"Status message appended to the chat view when a player joins the channel")
#define iTetPlayerLeftEventStatusMessageFormat		NSLocalizedStringFromTable(@"%@ has left the channel", @"NetworkController", @"Status message appended to the chat view when a player leaves the channel")

- (void)messageReceived:(iTetMessage*)message
{
	// Determine the nature of the message
	iTetMessageType type = [message type];
	switch (type)
	{
#pragma mark No Connecting (Error) Message
		case noConnectingMessage:
		{
			// Create an error, using the reason provided by the server
			NSDictionary* info = [NSDictionary dictionaryWithObject:[[message contents] objectForKey:iTetMessageNoConnectingReasonKey]
															 forKey:NSLocalizedFailureReasonErrorKey];
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
			[self sendMessage:[iTetMessage messageWithMessageType:heartbeatMessage]];
			break;
			
#pragma mark Client Info Request
		case clientInfoRequestMessage:
		{
			// Send client info to server
			iTetMessage* replyMessage = [iTetMessage messageWithMessageType:clientInfoReplyMessage];
			[[replyMessage contents] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]
										forKey:iTetMessageClientNameKey];
			[[replyMessage contents] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]
										forKey:iTetMessageClientVersionKey];
			[self sendMessage:replyMessage];
			break;
		}	
#pragma mark Player Number Message
		case tetrinetPlayerNumberMessage:
		case tetrifastPlayerNumberMessage:
		{
			// Read the player number
			NSInteger playerNumber = [[message contents] integerForKey:iTetMessagePlayerNumberKey];
			
			// Check if we've been assigned a player number yet
			if ([playersController localPlayer] == nil)
			{
				// Create the local player object
				[playersController createLocalPlayerWithNumber:playerNumber
													  nickname:[currentServer playerNickname]
													  teamName:[currentServer playerTeamName]];
				
				// Treat this as the sign of a successful connection
				[self setConnectionState:connected];
			}
			// Check if we're being moved to a new slot (probably a sign we've moved to a new channel)
			else if (playerNumber != [[playersController localPlayer] playerNumber])
			{
				[playersController changeLocalPlayerNumber:playerNumber];
			}
			
			// Send the local player's team name to the server
			iTetMessage* replyMessage = [iTetMessage messageWithMessageType:playerTeamMessage];
			[[replyMessage contents] setInteger:playerNumber
										 forKey:iTetMessagePlayerNumberKey];
			[[replyMessage contents] setObject:[currentServer playerTeamName]
										forKey:iTetMessagePlayerTeamNameKey];
			[self sendMessage:replyMessage];
			
			// Refresh channel list
			[channelsController refreshChannelList:self];
			
			break;
		}
#pragma mark Player Join Message
		case playerJoinMessage:
		{
			// Check that this isn't an echo of our own join event
			NSInteger playerNumber = [[message contents] integerForKey:iTetMessagePlayerNumberKey];
			if (playerNumber == [[playersController localPlayer] playerNumber])
				break;
			
			// Add a new player with the specified name and number
			NSString* nickname = [[message contents] objectForKey:iTetMessagePlayerNicknameKey];
			[playersController addPlayerWithNumber:playerNumber
										  nickname:nickname];
			
			// Add a status message to the chat view
			[chatController appendStatusMessage:[NSString stringWithFormat:iTetPlayerJoinedEventStatusMessageFormat, nickname]];
			
			// Refresh the channel list
			[channelsController refreshChannelList:self];
			
			break;
		}	
#pragma mark Player Leave Message
		case playerLeaveMessage:
		{
			// If this message refers to the local player, ignore
			NSInteger playerNumber = [[message contents] integerForKey:iTetMessagePlayerNumberKey];
			if (playerNumber == [[playersController localPlayer] playerNumber])
				break;
			
			// Look up the player in question
			iTetPlayer* player = [playersController playerNumber:playerNumber];
			
			// Append a status message
			[chatController appendStatusMessage:[NSString stringWithFormat:iTetPlayerLeftEventStatusMessageFormat, [player nickname]]];
			
			// Remove the player from the game
			[playersController removePlayer:player];
			
			// Refresh the channel list
			[channelsController refreshChannelList:self];
			
			break;
		}
#pragma mark Player Team Message
		case playerTeamMessage:
			// Change the specified player's team name
			[playersController setTeamName:[[message contents] objectForKey:iTetMessagePlayerTeamNameKey]
						   forPlayerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]];
			break;
			
#pragma mark Winlist Message
		case winlistMessage:
			// Pass the winlist entries to the winlist controller
			[winlistController parseWinlist:[[message contents] objectForKey:iTetMessageWinlistArrayKey]];
			break;
			
#pragma mark Partyline Messages
		case plineChatMessage:
		case plineActionMessage:
			// Add the message to the chat controller
			[chatController appendChatLine:[[message contents] objectForKey:iTetMessageChatContentsKey]
								fromPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]]
									action:(type == plineActionMessage)];
			break;
			
#pragma mark Game Chat Message
		case gameChatMessage:
		{
			// Hand the message to the game controller for processing
			[gameController chatMessageReceived:[[message contents] objectForKey:iTetMessageChatContentsKey]];
			
			break;
		}
#pragma mark New Game Message
		case tetrinetNewGameMessage:
		case tetrifastNewGameMessage:
			// Tell the gameController to start the game
			[gameController newGameWithPlayers:[playersController playerList]
										 rules:[iTetGameRules gameRulesFromArray:[[message contents] objectForKey:iTetMessageGameRulesArrayKey]
																	withGameType:[currentServer protocol]
																	 gameVersion:[currentServer gameVersion]]];
			break;
			
#pragma mark Server In-Game Message
		case inGameMessage:
			// Set all players except the local player to "playing"
			[playersController setAllRemotePlayersToPlaying];
			
			// Give the local player a "death field"
			[[playersController localPlayer] setField:[iTetField fieldWithRandomContents]];
			
			// Set the game view controller's state as "playing"
			[gameController setGameplayState:gamePlaying];
			
			break;
			
#pragma mark Pause/Resume Game Message
		case pauseResumeGameMessage:
		{
			// Get pause state
			BOOL pauseGame = [[message contents] boolForKey:iTetMessagePauseResumeRequestTypeKey];
			
			// Pause or resume the game
			if (pauseGame && ([gameController gameplayState] == gamePlaying))
			{
				// Pause the game
				[gameController pauseGame];
			}
			else if (!pauseGame && ([gameController gameplayState] == gamePaused))
			{
				// Resume the game
				[gameController resumeGame];
			}
			
			// Refresh the channel list
			[channelsController refreshChannelList:self];
			
			break;
		}
#pragma mark End of Game Message
		case endGameMessage:
			// End the game
			[gameController endGame];
			
			// If the user wants us to, automatically switch to the chat tab
			if ([[NSUserDefaults standardUserDefaults] boolForKey:iTetAutoSwitchChatAfterGamePrefKey])
				[windowController switchToChatTab:self];
			
			// Refresh the channel list
			[channelsController refreshChannelList:self];
			
			break;
			
#pragma mark Fieldstring Message
		case fieldstringMessage:
		{
			// Pass to the game controller
			[gameController fieldstringReceived:[[message contents] objectForKey:iTetMessageFieldstringKey]
									  forPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]]];
			break;
		}
#pragma mark Level Update Message
		case levelUpdateMessage:
		{
			// Check that the level update isn't an echo of one we just sent
			NSInteger playerNumber = [[message contents] integerForKey:iTetMessagePlayerNumberKey];
			if (playerNumber == [[playersController localPlayer] playerNumber])
				break;
			
			// Otherwise, update the specified player's level
			[playersController setLevel:[[message contents] integerForKey:iTetMessageLevelNumberKey]
						forPlayerNumber:playerNumber];
			break;
		}
#pragma mark Special Used/Lines Received Message
		case specialUsedMessage:
		{
			// Pass to game controller
			[gameController specialUsed:[[message contents] intForKey:iTetMessageSpecialTypeKey]
							   byPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]]
							   onPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessageTargetPlayerNumberKey]]];
			break;
		}
#pragma mark Player Lost Message
		case playerLostMessage:
			// Set the player to "not playing"
			[playersController setPlayerIsPlaying:NO
								  forPlayerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]];
			break;
			
#pragma mark Player Won Message
		case playerWonMessage:
			// Does nothing
			break;
			
		default:
			NSAssert2(NO, @"invalid message type in NetworkController -messageReceived: %d; contents: %@", type, [message contents]);
			break;
	}
}

#pragma mark -
#pragma mark Errors

#define iTetConnectionErrorAlertTitle					NSLocalizedStringFromTable(@"Connection error", @"NetworkController", @"Title of alert displayed when an error occurs while connecting or connected to a server")
#define iTetConnectionRefusedErrorAlertInformativeText	NSLocalizedStringFromTable(@"Connection refused. Check the server address and try again.", @"NetworkController", @"Informative text on alert displayed in the event of a 'connection refused' error when connecting to a server, and suggesting the user check the server address and retry")
#define iTetHostUnreachableErrorAlertInformativeText	NSLocalizedStringFromTable(@"Could not connect to server. Check that your computer is connected to the internet, then check the server address and try again.", @"NetworkController", @"Informative text on alert displayed in the event of a 'host unreachable' error when connecting to a server, suggesting the user check the computer's network status and the host address before retrying")
#define iTetPOSIXNetworkErrorAlertInformativeText		NSLocalizedStringFromTable(@"A connection error occurred:", @"NetworkController", @"Informative text prefixing information displayed on a generic connection error alert")
#define iTetNoConnectingErrorAlertInformativeText		NSLocalizedStringFromTable(@"Could not log in to server:", @"NetworkController", @"Informative text prefixing a reason received when a server won't allow the user to log in")
#define iTetUnknownNetworkErrorAlertInformativeText		NSLocalizedStringFromTable(@"An unknown error occurred:", @"NetworkController", @"Informative text prefixing information about an unknown connection error")
#define iTetErrorDomainLabel							NSLocalizedStringFromTable(@"Error domain:", @"NetworkController", @"Label for the domain of an unknown connection error")
#define iTetErrorCodeLabel								NSLocalizedStringFromTable(@"Error code:", @"NetworkController", @"Label for the code of an unknown connection error")

- (void)handleError:(NSError*)error
{
	// Change the connection state
	[self setConnectionState:connectionError];
	
	// Create an alert
	NSAlert* alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:iTetConnectionErrorAlertTitle];
	
	// Determine the type of error
	NSString* errorText;
	if ([[error domain] isEqualToString:NSPOSIXErrorDomain])
	{
		switch ([error code])
		{
			case ECONNREFUSED:
				errorText = iTetConnectionRefusedErrorAlertInformativeText;
				break;
			case EHOSTUNREACH:
				errorText = iTetHostUnreachableErrorAlertInformativeText;
				break;
			default:
				errorText = [NSString stringWithFormat:@"%@%C%@", iTetPOSIXNetworkErrorAlertInformativeText, NSLineSeparatorCharacter, [error localizedDescription]];
				break;
		}
	}
	else if ([[error domain] isEqualToString:iTetNetworkErrorDomain])
	{
		switch ([error code])
		{
			case iTetNoConnectingError:
				errorText = [NSString stringWithFormat:@"%@%C%@", iTetNoConnectingErrorAlertInformativeText, NSLineSeparatorCharacter, [error localizedFailureReason]];
				break;
			default:
				errorText = [NSString stringWithFormat:@"%@%C%@ %@%C%@ %d", iTetUnknownNetworkErrorAlertInformativeText, NSLineSeparatorCharacter, iTetErrorDomainLabel, [error domain], NSLineSeparatorCharacter, iTetErrorCodeLabel, [error code]];
				break;
		}
	}
	else
	{
		errorText = [NSString stringWithFormat:@"%@%C%@ %@%C%@ %d", iTetUnknownNetworkErrorAlertInformativeText, NSLineSeparatorCharacter, iTetErrorDomainLabel, [error domain], NSLineSeparatorCharacter, iTetErrorCodeLabel, [error code]];
	}
	
	// Add the error information to the alert, along with an "Okay" button
	[alert setInformativeText:errorText];
	[alert addButtonWithTitle:iTetOkayButtonTitle];
	
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

- (NSString*)currentServerAddress
{
	return [currentServer serverAddress];
}

#define iTetConnectMenuItemTitle			NSLocalizedStringFromTable(@"Connect to Server...", @"NetworkController", @"Title of menu item used to open a connection to a server")
#define iTetDisconnectedStatusMessage		NSLocalizedStringFromTable(@"Connection Closed", @"NetworkController", @"Status message appended to the chat view after successfully disconnecting from a server")
#define iTetDisconnectedStatusLabel			NSLocalizedStringFromTable(@"Disconnected", @"NetworkController", @"Status label displayed at bottom of window after successfully disconnecting from a server")
#define iTetServerDisconnectedStatusLabel	NSLocalizedStringFromTable(@"Server closed connection", @"NetworkController", @"Status label displayed at bottom of window when the server closes the remote end of the connection")

#define iTetCancelConnectionButtonTitle		NSLocalizedStringFromTable(@"Cancel Connection", @"NetworkController", @"Title of toolbar button used to cancel when attempting to open a connection to a server")
#define iTetCancelConnectionMenuItemTitle	NSLocalizedStringFromTable(@"Cancel Connection in Progress", @"NetworkController", @"Title of menu item used to cancel when attempting to open a connection to a server")
#define iTetConnectingStatusLabelFormat		NSLocalizedStringFromTable(@"Connecting to server %@...", @"NetworkController", @"Status label displayed at bottom of window when a new connection is being opened to a server")

#define iTetConnectionOpenedStatusMessage	NSLocalizedStringFromTable(@"Connection Opened", @"NetworkController", @"Status message appended to the chat view after successfully opening a connection to a server")
#define iTetLoggingInStatusLabelFormat		NSLocalizedStringFromTable(@"Logging in as %@...", @"NetworkController", @"Status label displayed at bottom of window while logging in to a server")

#define iTetConnectionCanceledStatusLabel	NSLocalizedStringFromTable(@"Connection canceled", @"NetworkController", @"Status label displayed at the bottom of the window after cancelling a connection to a server")

#define iTetDisconnectButtonTitle			NSLocalizedStringFromTable(@"Disconnect", @"NetworkController", @"Title of button or toolbar button used to close an open connection to a server")
#define iTetDisconnectMenuItemTitle			NSLocalizedStringFromTable(@"Disconect from Server", @"NetworkController", @"Title of menu item used to close an open connection to a server")
#define iTetConnectedStatusLabel			NSLocalizedStringFromTable(@"Connected", @"NetworkController", @"Status label displayed at bottom of window while connected to a server")

#define iTetDisconnectingStatusLabel		NSLocalizedStringFromTable(@"Disconnecting...", @"NetworkController", @"Status label displayed at bottom of window while disconnecting from a server")

#define iTetConnectionErrorStatusMessage	NSLocalizedStringFromTable(@"Connection Error", @"NetworkController", @"Status message appended to the chat view if a connection error occurs")
#define iTetConnectionErrorStatusLabel		NSLocalizedStringFromTable(@"Connection error occurred", @"NetworkController", @"Status label displayed at bottom of window if a connection error occurs")

- (void)setConnectionState:(iTetConnectionState)newState
{
	if (connectionState == newState)
		return;
	
	switch (newState)
	{
		case disconnected:
			// Reset the connection toolbar item
			[connectionButton setLabel:iTetConnectButtonTitle];
			[connectionButton setImage:[NSImage imageNamed:@"Network"]];
			
			// Reset the connection menu item
			[connectionMenuItem setTitle:iTetConnectMenuItemTitle];
			[connectionMenuItem setKeyEquivalent:@"o"];
			
			// If the connection was not canceled or errored-out, this was a "clean" disconnect
			if ((connectionState != connectionError) && (connectionState != canceled))
			{
				// Append a status message to the chat tab
				[chatController appendStatusMessage:iTetDisconnectedStatusMessage];
				
				// Change the connection status label
				if (connectionState != disconnecting)
				{
					// If the connection closed unexpectedly, blame the server
					[connectionStatusLabel setStringValue:iTetServerDisconnectedStatusLabel];
					
					// Make sure the progress indicator is stopped and hidden
					[connectionProgressIndicator stopAnimation:self];
					[connectionProgressIndicator setHidden:YES];
				}
				else
				{
					[connectionStatusLabel setStringValue:iTetDisconnectedStatusLabel];
				}
			}
			
			break;
			
		case connecting:
			// Change the connection toolbar and menu items to "abort" actions
			[connectionButton setLabel:iTetCancelConnectionButtonTitle];
			[connectionButton setImage:[NSImage imageNamed:@"Cancel Red Button"]];
			[connectionMenuItem setTitle:iTetCancelConnectionMenuItemTitle];
			[connectionMenuItem setKeyEquivalent:@"d"];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:[NSString stringWithFormat:iTetConnectingStatusLabelFormat, [currentServer serverAddress]]];
			
			// Reveal and start the progress indicator
			[connectionProgressIndicator setHidden:NO];
			[connectionProgressIndicator startAnimation:self];
			
			break;
			
		case login:
			// Clear the chat views, and append a status message on the chat tab
			[chatController clearChat];
			[gameController clearChat];
			[chatController appendStatusMessage:iTetConnectionOpenedStatusMessage];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:[NSString stringWithFormat:iTetLoggingInStatusLabelFormat, [currentServer playerNickname]]];
			
			break;
			
		case canceled:
			// Stop and hide the progress indicator
			[connectionProgressIndicator stopAnimation:self];
			[connectionProgressIndicator setHidden:YES];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:iTetConnectionCanceledStatusLabel];
			
			// If we had already opened the connection, append a status message indicating we are closing it
			if (connectionState == login)
				[chatController appendStatusMessage:iTetDisconnectedStatusMessage];
			
			break;
			
		case connected:
			// Stop and hide the progress indicator
			[connectionProgressIndicator stopAnimation:self];
			[connectionProgressIndicator setHidden:YES];
			
			// Change the connection toolbar and menu items to "disconnect" actions
			[connectionButton setLabel:iTetDisconnectButtonTitle];
			[connectionButton setImage:[NSImage imageNamed:@"Eject Blue Button"]];
			[connectionMenuItem setTitle:iTetDisconnectMenuItemTitle];
			[connectionMenuItem setKeyEquivalent:@"d"];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:iTetConnectedStatusLabel];
			
			// Attempt to retrieve the server's channel list
			[channelsController requestChannelListFromServer:currentServer];
			
			// If the user wants us to, automatically switch to the chat tab
			if ([[NSUserDefaults standardUserDefaults] boolForKey:iTetAutoSwitchChatOnConnectPrefKey])
				[windowController switchToChatTab:self];
			
			break;
			
		case disconnecting:
			// Change the connection status label
			[connectionStatusLabel setStringValue:iTetDisconnectingStatusLabel];
			
			break;
			
		case connectionError:
			// If we were connecting, stop and hide the progress indicator
			if ((connectionState == connecting) || (connectionState == login))
			{
				// Stop and hide the progress indicator
				[connectionProgressIndicator stopAnimation:self];
				[connectionProgressIndicator setHidden:YES];
			}
			
			// If the connection was open when the error occurred, append a status message
			if ((connectionState == connected) || (connectionState == login))
				[chatController appendStatusMessage:iTetConnectionErrorStatusMessage];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:iTetConnectionErrorStatusLabel];
			
			break;
	}
	
	connectionState = newState;
}
@synthesize connectionState;

- (BOOL)connectionOpen
{
	return ([self connectionState] == connected);
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
	NSSet* keys = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"connectionOpen"])
		keys = [keys setByAddingObject:@"connectionState"];
	
	return keys;
}

@end
