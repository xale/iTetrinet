//
//  iTetAppController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import "iTetAppController.h"

#import "iTetNetworkController.h"
#import "iTetIncomingMessages.h"
#import "iTetOutgoingMessages.h"

#import "iTetPreferencesController.h"

#import "iTetGameViewController.h"
#import "iTetChatViewController.h"
#import "iTetWinlistViewController.h"

#import "iTetPreferencesWindowController.h"

#import "iTetServerInfo.h"
#import "iTetLocalPlayer.h"
#import "iTetGameRules.h"

#import "NSMutableDictionary+KeyBindings.h"
#import "NSString+ASCIIData.h"

#import "iTetProtocolTransformer.h"
#import "iTetSpecialNameTransformer.h"
#import "iTetWinlistEntryTypeImageTransformer.h"

@implementation iTetAppController

+ (void)initialize
{
	// Register value transformers
	// Protocol enum to name
	NSValueTransformer* transformer = [[[iTetProtocolTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer
									forName:iTetProtocolTransformerName];
	// Special code/number to name
	transformer = [[[iTetSpecialNameTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer
									forName:iTetSpecialNameTransformerName];
	// Winlist entry type to image
	transformer = [[[iTetWinlistEntryTypeImageTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer
									forName:iTetWinlistEntryTypeImageTransformerName];
	
	// Seed random number generator
	srandom(time(NULL));
}

- (id)init
{
	// Create the network controller, with this object as the delegate for
	// messages recieved from the server
	networkController = [[iTetNetworkController alloc] initWithDelegate:self];
	
	// Create the players array (initially filled with NSNull placeholders)
	players = [[NSMutableArray alloc] initWithCapacity:ITET_MAX_PLAYERS];
	for (NSInteger i = 0; i < ITET_MAX_PLAYERS; i++)
		[players addObject:[NSNull null]];
	
	return self;
}

- (void)awakeFromNib
{
	// Add a border to the bottom of the window (this can be done in IB, but only for 10.6+)
	[window setAutorecalculatesContentBorderThickness:NO
											  forEdge:NSMinYEdge];
	[window setContentBorderThickness:25
							  forEdge:NSMinYEdge];
}

- (void)dealloc
{	
	[networkController release];
	[prefsWindowController release];
	[players release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)openCloseConnection:(id)sender
{
	// If there is already a connection open, disconnect
	if ([networkController connected])
	{
		// If local player is playing a game, ask the user before disconnecting
		if ([[self localPlayer] isPlaying])
		{
			// Create an alert
			NSAlert* alert = [[[NSAlert alloc] init] autorelease];
			[alert setMessageText:@"Game in Progress"];
			[alert setInformativeText:@"A game is currently in progress. Are you sure you want to disconnect from the server?"];
			[alert addButtonWithTitle:@"Disconnect"];
			[alert addButtonWithTitle:@"Continue Playing"];
			
			// Run the alert as a sheet
			[alert beginSheetModalForWindow:window
							  modalDelegate:self
							 didEndSelector:@selector(disconnectWithGameInProgressAlertDidEnd:returnCode:contextInfo:)
								contextInfo:NULL];
			
			return;
		}
		
		// Otherwise, just disconnect from the server
		[networkController disconnect];
		
		return;
	}
	
	// If we are attempting to open a connection, abort the attempt
	if (connectionTimer != nil)
	{
		[networkController disconnect];
		
		// Invalidate the connection timer
		[connectionTimer invalidate];
		connectionTimer = nil;
		
		// Stop and hide the progress indicator
		[connectionProgressIndicator stopAnimation:self];
		[connectionProgressIndicator setHidden:YES];
		
		// Change the connection status label
		[connectionStatusLabel setStringValue:@"Connection canceled"];
		
		// Reset the label and image on the connection toolbar item
		[connectionButton setLabel:@"Connect"];
		[connectionButton setImage:[NSImage imageNamed:@"Network"]];
		
		// Reset the connection menu item
		[connectionMenuItem setTitle:@"Connect to Server..."];
		[connectionMenuItem setKeyEquivalent:@"o"];
		
		return;
	}
	
	// Otherwise, open the server list
	
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
	[dialog beginSheetModalForWindow:window
					   modalDelegate:self
					  didEndSelector:@selector(connectAlertDidEnd:returnCode:contextInfo:)
						 contextInfo:NULL];
}

- (IBAction)startStopGame:(id)sender
{	
	// Check if a game is already in progress
	if ([gameController gameplayState] != gameNotPlaying)
	{
		// Confirm with user before ending game
		// Create a confirmation dialog
		NSAlert* dialog = [[[NSAlert alloc] init] autorelease];
		[dialog setMessageText:@"End Game in Progress?"];
		[dialog setInformativeText:@"Are you sure you want to end the game in progress?"];
		[dialog addButtonWithTitle:@"End Game"];
		[dialog addButtonWithTitle:@"Continue Playing"];
		
		// Run the dialog as a window-modal sheet
		[dialog beginSheetModalForWindow:window
						   modalDelegate:self
						  didEndSelector:@selector(stopGameAlertDidEnd:returnCode:contextInfo:)
							 contextInfo:NULL];
	}
	else
	{
		// Start the game
		[networkController sendMessage:[iTetStartStopGameMessage startMessageFromSender:[self localPlayer]]];
	}
}

- (IBAction)forfeitGame:(id)sender
{
	// Create a confirmation dialog
	NSAlert* dialog = [[[NSAlert alloc] init] autorelease];
	[dialog setMessageText:@"Forfeit Game?"];
	[dialog setInformativeText:@"Are you sure you want to forfeit the current game?"];
	[dialog addButtonWithTitle:@"Forfeit"];
	[dialog addButtonWithTitle:@"Continue Playing"];
	
	// Run the dialog as a window-modal sheet
	[dialog beginSheetModalForWindow:window
					   modalDelegate:self
					  didEndSelector:@selector(forfeitDialogDidEnd:returnCode:contextInfo:)
						 contextInfo:NULL];
}

- (IBAction)pauseResumeGame:(id)sender
{
	// Check if game is already paused
	if ([gameController gameplayState] == gamePaused)
	{	
		// Send a message asking the server to resume play
		[networkController sendMessage:[iTetPauseResumeGameMessage resumeMessageFromSender:[self localPlayer]]];
	}
	else
	{
		// Send a message asking the server to pause
		[networkController sendMessage:[iTetPauseResumeGameMessage pauseMessageFromSender:[self localPlayer]]];
	}
}

- (IBAction)showPreferences:(id)sender
{
	if (prefsWindowController == nil)
		prefsWindowController = [[iTetPreferencesWindowController alloc] init];
	
	[prefsWindowController showWindow:self];
	[[prefsWindowController window] makeKeyAndOrderFront:self];
}

- (void)openPreferencesTabNumber:(NSInteger)tabNumber
{
	[self showPreferences:self];
	[prefsWindowController displayViewControllerAtIndex:tabNumber];
}

- (IBAction)switchToGameTab:(id)sender
{
	[tabView selectTabViewItemAtIndex:0];
}

- (IBAction)switchToChatTab:(id)sender
{
	[tabView selectTabViewItemAtIndex:1];
}

- (IBAction)switchToWinlistTab:(id)sender
{
	[tabView selectTabViewItemAtIndex:2];
}

#pragma mark -
#pragma mark Modal Sheet Callbacks

NSString* const iTetServerConnectionInfoFormat = @"Attempting to connect to server %@...";

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
		[self openPreferencesTabNumber:serversPreferencesTab];
		return;
	}
	
	// Otherwise, open a connection to the server
	iTetServerInfo* server = [[serverListController selectedObjects] objectAtIndex:0];
	[networkController connectToServer:server];
	
	// Change the "connect" button to an "abort" button
	[connectionButton setLabel:@"Cancel Connection"];
	[connectionButton setImage:[NSImage imageNamed:@"Cancel Red Button"]];
	
	// Reveal and start the progress indicator
	[connectionProgressIndicator setHidden:NO];
	[connectionProgressIndicator startAnimation:self];
	
	// Change the connection status label
	[connectionStatusLabel setStringValue:[NSString stringWithFormat:iTetServerConnectionInfoFormat, [server address]]];
	
	// Start the connection timer
	connectionTimer = [NSTimer scheduledTimerWithTimeInterval:[[iTetPreferencesController preferencesController] connectionTimeout]
													   target:self
													 selector:@selector(connectionTimedOut:)
													 userInfo:nil
													  repeats:NO];
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
	[networkController disconnect];
}

- (void)stopGameAlertDidEnd:(NSAlert*)dialog
				 returnCode:(NSInteger)returnCode
				contextInfo:(void*)contextInfo
{
	// If the user pressed "continue playing", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// Send the server a "stop game" message
	[networkController sendMessage:[iTetStartStopGameMessage stopMessageFromSender:[self localPlayer]]];
}

- (void)forfeitDialogDidEnd:(NSAlert*)dialog
				 returnCode:(NSInteger)returnCode
				contextInfo:(void*)contextInfo
{
	// If the user pressed "continue playing", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// Forfeit the current game
	[gameController playerLost];
}

#pragma mark -
#pragma mark Connection Timeout Callback

- (void)connectionTimedOut:(NSTimer*)timer
{
	// Tell the network controller to abort the connection
	[networkController disconnect];
	
	// Nil the timer
	connectionTimer = nil;
	
	// Stop and hide the progress indicator
	[connectionProgressIndicator stopAnimation:self];
	[connectionProgressIndicator setHidden:YES];
	
	// Change the connection status label
	[connectionStatusLabel setStringValue:@"Connection failed"];
	
	// Display an alert
	NSAlert* alert = [NSAlert alertWithMessageText:@"Unable to Connect"
									 defaultButton:@"Okay"
								   alternateButton:nil
									   otherButton:nil
						 informativeTextWithFormat:@"Check server address and try again."];
	
	[alert beginSheetModalForWindow:window
					  modalDelegate:self
					 didEndSelector:@selector(timedOutAlertEnded:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)timedOutAlertEnded:(NSAlert*)alert
				returnCode:(NSInteger)returnCode
			   contextInfo:(void*)contextInfo
{
	// Reset the connection button
	[connectionButton setLabel:@"Connect"];
	[connectionButton setImage:[NSImage imageNamed:@"Network"]];
}

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Determine which item we are looking at based on its action
	SEL itemAction = [item action];
	
	// Get the current operator player
	iTetPlayer* op = [self operatorPlayer];
	
	// "New Game" button/menu item
	if (itemAction == @selector(startStopGame:))
	{
		return ([networkController connected] && [op isEqual:[self localPlayer]]);
	}
	
	// "Forfeit" button/menu item
	if (itemAction == @selector(forfeitGame:))
	{
		return (([gameController gameplayState] != gameNotPlaying) && [[self localPlayer] isPlaying]);
	}
	
	// "Pause" button/menu item
	if (itemAction == @selector(pauseResumeGame:))
	{
		return (([gameController gameplayState] != gameNotPlaying) && [op isEqual:[self localPlayer]]);
	}
	
	return YES;
}

#pragma mark -
#pragma mark Network Controller Delegate Methods

- (void)connectionOpened
{
	// Invalidate the connection timer
	[connectionTimer invalidate];
	connectionTimer = nil;
	
	// Stop and hide the progress indicator
	[connectionProgressIndicator stopAnimation:self];
	[connectionProgressIndicator setHidden:YES];
	
	// Change the connection status label
	[connectionStatusLabel setStringValue:@"Connected"];
	
	// Change the connection toolbar item
	[connectionButton setLabel:@"Disconnect"];
	[connectionButton setImage:[NSImage imageNamed:@"Eject Blue Button"]];
	
	// Change the connection menu item
	[connectionMenuItem setTitle:@"Disconnect from Server"];
	[connectionMenuItem setKeyEquivalent:@"w"];
	
	// Clear the chat views
	[chatController clearChat];
	[chatController appendStatusMessage:@"Connection Opened"];
	[gameController clearChat];
}

- (void)connectionClosed
{
	[self removeAllPlayers];
	[gameController setCurrentGameRules:nil];
	
	// Change the connection status label
	[connectionStatusLabel setStringValue:@"Disconnected"];
	
	// Reset all toolbar and menu items
	// Change the connection toolbar item
	[connectionButton setLabel:@"Connect"];
	[connectionButton setImage:[NSImage imageNamed:@"Network"]];
	
	// Change the connection menu item
	[connectionMenuItem setTitle:@"Connect to Server..."];
	[connectionMenuItem setKeyEquivalent:@"o"];
	
	// Change the "end game" toolbar item
	[gameButton setLabel:@"New Game"];
	[gameButton setImage:[NSImage imageNamed:@"Play Green Button"]];
	
	// Change the "new game" menu item
	[gameMenuItem setTitle:@"New Game"];
	[gameMenuItem setKeyEquivalent:@"n"];
	
	// Change the "resume" button back into pause button
	[pauseButton setLabel:@"Pause Game"];
	[pauseButton setImage:[NSImage imageNamed:@"Pause Blue Button"]];
	
	// Change the menu item
	[pauseMenuItem setTitle:@"Pause Game"];
	
	[chatController appendStatusMessage:@"Connection Closed"];
}

- (void)connectionError:(NSError*)error
{
	NSAlert* alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Error connecting to server"];
	
	// If we were attempting to connect, invalidate the timeout timer
	if (connectionTimer != nil)
	{
		[connectionTimer invalidate];
		connectionTimer = nil;
		
		// Stop and hide the progress indicator
		[connectionProgressIndicator stopAnimation:self];
		[connectionProgressIndicator setHidden:YES];	
	}
	
	// Change the connection status label
	[connectionStatusLabel setStringValue:@"Error connecting to server"];
	
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
				[errorText appendString:@"Error connecting to server:\n"];
				[errorText appendString:[error localizedDescription]];
				break;
		}
	}
	else if ([[error domain] isEqualToString:iTetNetworkErrorDomain])
	{
		switch ([error code])
		{
			case iTetNoConnectingError:
				[errorText appendString:@"Server refused connection. Reason:\n"];
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
	[alert beginSheetModalForWindow:window
					  modalDelegate:self
					 didEndSelector:@selector(connectionErrorAlertEnded:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)connectionErrorAlertEnded:(NSAlert*)alert
					   returnCode:(NSInteger)returnCode
					  contextInfo:(void*)contextInfo
{
	// Reset the connection button
	[connectionButton setLabel:@"Connect"];
	[connectionButton setImage:[NSImage imageNamed:@"Network"]];
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
			[self connectionError:error];
			break;
		}
			
#pragma mark Server Heartbeat
		case heartbeatMessage:
			// Send a keepalive message
			[networkController sendMessage:[iTetHeartbeatMessage message]];
			break;
			
#pragma mark Client Info Request
		case clientInfoRequestMessage:
			// Send client info to server
			[networkController sendMessage:[iTetClientInfoReplyMessage message]];
			break;
			
#pragma mark Player Number Message
		case playerNumberMessage:
			// Set the local player's number
			[self setLocalPlayerNumber:[(iTetPlayerNumberMessage*)message playerNumber]];
			
			// Send the player's team name to the server
			[networkController sendMessage:[iTetPlayerTeamMessage messageForPlayer:[self localPlayer]]];
			break;
			
#pragma mark Player Join Message
		case playerJoinMessage:
		{
			// Add a new player with the specified name and number
			iTetPlayerJoinMessage* joinMessage = (iTetPlayerJoinMessage*)message;
			[self addPlayerWithNumber:[joinMessage playerNumber]
							 nickname:[joinMessage nickname]];
			
			// Add a message to the chat view
			[chatController appendStatusMessage:[NSString stringWithFormat:@"Player %@ has joined the channel", [joinMessage nickname]]];
			break;
		}
			
#pragma mark Player Leave Message
		case playerLeaveMessage:
		{
			// Get player number
			NSInteger playerNum = [(iTetPlayerLeaveMessage*)message playerNumber];
			
			// Add a chat line
			[chatController appendStatusMessage:[NSString stringWithFormat:@"Player %@ has left the channel", [self playerNameForNumber:playerNum]]];
			
			// Remove the player from the game
			[self removePlayerNumber:playerNum];
			break;
		}
			
#pragma mark Player Team Message
		case playerTeamMessage:
		{
			// Change the specified player's team name
			iTetPlayerTeamMessage* teamMessage = (iTetPlayerTeamMessage*)message;
			[[self playerNumber:[teamMessage playerNumber]] setTeamName:[teamMessage teamName]];
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
							fromPlayerName:[self playerNameForNumber:[plineMessage senderNumber]]
									action:(type == plineActionMessage)];
			break;
		}
			
#pragma mark Game Chat Message
		case gameChatMessage:
		{
			// Check if the first space-delimited word of the message is or contains a player's name
			iTetGameChatMessage* chatMessage = (iTetGameChatMessage*)message;
			for (iTetPlayer* player in [self playerList])
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
			[self switchToGameTab:self];
			
			// Tell the gameController to start the game
			[gameController newGameWithPlayers:[self playerList]
										 rules:[iTetGameRules gameRulesFromArray:[(iTetNewGameMessage*)message rulesList]
																	withGameType:[[networkController currentServer] protocol]]];
			
			// Change the "new game" toolbar item
			[gameButton setLabel:@"End Game"];
			[gameButton setImage:[NSImage imageNamed:@"Stop Red Button"]];
			
			// Change the "new game" menu item
			[gameMenuItem setTitle:@"End Game..."];
			[gameMenuItem setKeyEquivalent:@"e"];
			break;
			
#pragma mark Server In-Game Message
		case inGameMessage:
			// Set all players to "playing" (server will send "playerlost" for players not playing)
			for (iTetPlayer* player in [self playerList])
			{
				if (![player isKindOfClass:[iTetLocalPlayer class]])
					[player setPlaying:YES];
			}
			
			// Set the game view controller's state as "playing"
			[gameController setGameplayState:gamePlaying];
			
			// Tell the game view controller to send the local player's field to the server
			[gameController sendFieldstring];
			
			// Change the "new game" toolbar item
			[gameButton setLabel:@"End Game"];
			[gameButton setImage:[NSImage imageNamed:@"Stop Red Button"]];
			
			// Change the "new game" menu item
			[gameMenuItem setTitle:@"End Game..."];
			[gameMenuItem setKeyEquivalent:@"e"];
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
				
				// Change the pause button to a "resume" button
				[pauseButton setLabel:@"Resume Game"];
				[pauseButton setImage:[NSImage imageNamed:@"Play Blue Button"]];
				
				// Change the menu item
				[pauseMenuItem setTitle:@"Resume Game"];
			}
			else if (!pauseGame && ([gameController gameplayState] == gamePaused))
			{
				// Make sure we have the game tab open
				[self switchToGameTab:self];
				
				// Resume the game
				[gameController resumeGame];
				
				// Change the "resume" button back into pause button
				[pauseButton setLabel:@"Pause Game"];
				[pauseButton setImage:[NSImage imageNamed:@"Pause Blue Button"]];
				
				// Change the menu item
				[pauseMenuItem setTitle:@"Pause Game"];
			}
			break;
		}
			
#pragma mark End Game Message
		case endGameMessage:
			// End the game
			[gameController endGame];
			
			// Change the "end game" toolbar item
			[gameButton setLabel:@"New Game"];
			[gameButton setImage:[NSImage imageNamed:@"Play Green Button"]];
			
			// Change the "end game" menu item
			[gameMenuItem setTitle:@"New Game"];
			[gameMenuItem setKeyEquivalent:@"n"];
			
			// Change the "resume" button back into pause button
			[pauseButton setLabel:@"Pause Game"];
			[pauseButton setImage:[NSImage imageNamed:@"Pause Blue Button"]];
			
			// Change the menu item
			[pauseMenuItem setTitle:@"Pause Game"];
			break;
			
#pragma mark Fieldstring Message
		case fieldstringMessage:
		{
			// Pass to the game controller
			iTetFieldstringMessage* fieldMessage = (iTetFieldstringMessage*)message;
			[gameController fieldstringReceived:[fieldMessage fieldstring]
									  forPlayer:[self playerNumber:[fieldMessage playerNumber]]
								  partialUpdate:[fieldMessage isPartialUpdate]];
			break;
		}
			
#pragma mark Level Update Message
		case levelUpdateMessage:
		{
			// Update the specified player's level
			iTetLevelUpdateMessage* levelMessage = (iTetLevelUpdateMessage*)message;
			[[self playerNumber:[levelMessage playerNumber]] setLevel:[levelMessage level]];
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
				sender = [self playerNumber:[spMessage senderNumber]];
			if ([spMessage targetNumber] > 0)
				target = [self playerNumber:[spMessage targetNumber]];
			
			// Pass to game controller
			[gameController specialUsed:[spMessage specialType]
							   byPlayer:sender
							   onPlayer:target];
			break;
		}
			
#pragma mark Player Lost Message
		case playerLostMessage:
			// Set the player to "not playing"
			[[self playerNumber:[(iTetPlayerLostMessage*)message playerNumber]] setPlaying:NO];
			
			// FIXME: anything else?
			break;
			
#pragma mark Player Won Message
		case playerWonMessage:
			// FIXME: should this do anything?
			break;
		
		default:
			NSLog(@"WARNING: invalid message type in appController messageReceived:");
			break;
	}
}

#pragma mark -
#pragma mark NSWindow Delegate Methods

- (void)windowWillClose:(NSNotification*)n
{
	[NSApp terminate:self];
}

#pragma mark -
#pragma mark Players

#define iTetCheckPlayerNumber(n) NSParameterAssert(((n) > 0) && ((n) <= ITET_MAX_PLAYERS))

- (void)setLocalPlayerNumber:(NSInteger)number
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Check that the assigned slot is not already occupied
	if ([self playerNumber:number] != nil)
	{
		NSLog(@"WARNING: local player assigned to occupied player slot");
		playerCount--;
	}
	
	// Check if our player already exists; if so, this is a move operation
	if ([self localPlayer] != nil)
	{
		// Clear the old location in the players array
		[players replaceObjectAtIndex:([[self localPlayer] playerNumber] - 1)
						   withObject:[NSNull null]];
		
		// Change the local player's number
		[[self localPlayer] setPlayerNumber:number];
		
		// Move to the new location in the players array
		[players replaceObjectAtIndex:(number - 1)
						   withObject:[self localPlayer]];
		
		// No need to notify game controller; field assignment will not change
	}
	else
	{
		// Create the local player
		[self setLocalPlayer:[iTetLocalPlayer playerWithNickname:[[networkController currentServer] nickname]
														  number:number
														teamName:[[networkController currentServer] playerTeam]]];
		
		// Place the player in the players array
		[players replaceObjectAtIndex:(number - 1)
						   withObject:[self localPlayer]];
		
		// Update player count
		playerCount++;
	}
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)addPlayerWithNumber:(NSInteger)number
				   nickname:(NSString*)nick
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Check that the slot is not already occupied
	if ([self playerNumber:number] != nil)
	{
		// (some servers echo our own player-join event back to us; ignore this and don't add a new player)
		if (number == [localPlayer playerNumber])
			return;
		
		NSLog(@"WARNING: new player assigned to occupied player slot");
		playerCount--;
	}
	
	// Create the new player
	[players replaceObjectAtIndex:(number - 1)
					   withObject:[iTetPlayer playerWithNickname:nick
														  number:number]];
	
	// Update player count
	playerCount++;
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)removePlayerNumber:(NSInteger)number
{
	// Sanity checks
	iTetCheckPlayerNumber(number);
	if ([self playerNumber:number] == nil)
	{
		NSLog(@"WARNING: attempt to remove player in empty player slot");
		return;
	}
	
	[self willChangeValueForKey:@"playerList"];
	
	// Remove the player
	[players replaceObjectAtIndex:(number - 1)
					   withObject:[NSNull null]];
	
	// Update player count
	playerCount--;
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)removeAllPlayers
{
	// Remove the local player
	[self setLocalPlayer:nil];
	
	[self willChangeValueForKey:@"playerList"];
	
	// Remove all players in the players array
	for (NSInteger i = 0; i < ITET_MAX_PLAYERS; i++)
	{
		[players replaceObjectAtIndex:i
						   withObject:[NSNull null]];
	}
	
	// Reset the player count
	playerCount = 0;
	
	[self didChangeValueForKey:@"playerList"];
}

#pragma mark -
#pragma mark Accessors

- (NSArray*)playerList
{
	return [players filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", [NSNull null]]];
}

- (NSNumber*)averagePlayerLevel
{
	NSInteger total = 0, count = 0;
	for (iTetPlayer* player in [self playerList])
	{
		if ([player isPlaying])
		{	
			total += [player level];
			count++;
		}
	}
	
	if (count > 0)
		return [NSNumber numberWithInteger:(total / count)];
	
	return nil;
}

@synthesize localPlayer;

-(iTetPlayer*)remotePlayer1
{
	return [self remotePlayerNumber:1];
}
-(iTetPlayer*)remotePlayer2
{
	return [self remotePlayerNumber:2];
}
-(iTetPlayer*)remotePlayer3
{
	return [self remotePlayerNumber:3];
}
-(iTetPlayer*)remotePlayer4
{
	return [self remotePlayerNumber:4];
}
-(iTetPlayer*)remotePlayer5
{
	return [self remotePlayerNumber:5];
}
- (iTetPlayer*)remotePlayerNumber:(NSInteger)n
{	
	// Shift index to account for the local player's number
	if ([[self localPlayer] playerNumber] > n)
		n--;
	
	// Return the player at that index, or nil
	id player = [players objectAtIndex:n];
	if (player == [NSNull null])
		return nil;
	
	return (iTetPlayer*)player;
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
	NSSet* keys = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key rangeOfString:@"remotePlayer"].location != NSNotFound)
	{
		keys = [keys setByAddingObjectsFromSet:[NSSet setWithObjects:@"playerList", @"localPlayer", nil]];
	}
	else if ([key isEqualToString:@"averagePlayerLevel"])
	{
		keys = [keys setByAddingObjectsFromSet:[NSSet setWithObjects:@"localPlayer.level", @"remotePlayer1.level", @"remotePlayer2.level", @"remotePlayer3.level", @"remotePlayer4.level", @"remotePlayer5.level", @"localPlayer.isPlaying", @"remotePlayer1.isPlaying", @"remotePlayer2.isPlaying", @"remotePlayer3.isPlaying", @"remotePlayer4.isPlaying", @"remotePlayer5.isPlaying", nil]];
	}
	
	return keys;
}

- (iTetPlayer*)playerNumber:(NSInteger)number
{
	iTetCheckPlayerNumber(number);
	
	id player = [players objectAtIndex:(number - 1)];
	if (player == [NSNull null])
		return nil;
	
	return (iTetPlayer*)player;
}

- (iTetPlayer*)operatorPlayer
{
	// Return the player with the lowest player number (first player in the array)
	for (id player in players)
	{
		if (player != [NSNull null])
			return (iTetPlayer*)player;
	}
	
	return nil;
}

NSString* const iTetServerPlayerNamePlaceholder = @"SERVER";

- (NSString*)playerNameForNumber:(NSInteger)number
{
	if (number == 0)
		return iTetServerPlayerNamePlaceholder;
	else
		return [[self playerNumber:number] nickname];
}

@synthesize networkController;

- (iTetPreferencesController*)preferencesController
{
	return [iTetPreferencesController preferencesController];
}

@end
