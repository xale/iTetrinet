//
//  iTetAppController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import "iTetAppController.h"
#import "iTetNetworkController.h"
#import "iTetPreferencesController.h"
#import "iTetGameViewController.h"
#import "iTetChatViewController.h"
#import "iTetWinlistViewController.h"
#import "iTetTextAttributesController.h"
#import "iTetServerInfo.h"
#import "iTetLocalPlayer.h"
#import "iTetGameRules.h"
#import "NSMutableDictionary+KeyBindings.h"
#import "iTetPreferencesWindowController.h"
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

NSString* const StartGameFormat =	@"startgame 1 %d";
NSString* const StopGameFormat =	@"startgame 0 %d";

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
		[networkController sendMessage:[NSString stringWithFormat:StartGameFormat, [[self localPlayer] playerNumber]]];
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

NSString* const PauseGameFormat =	@"pause 1 %d";
NSString* const ResumeGameFormat =	@"pause 0 %d";

- (IBAction)pauseResumeGame:(id)sender
{
	// Check if game is already paused
	if ([gameController gameplayState] == gamePaused)
	{	
		// Send a message asking the server to resume play
		[networkController sendMessage:[NSString stringWithFormat:ResumeGameFormat, [[self localPlayer] playerNumber]]];
	}
	else
	{
		// Send a message asking the server to pause
		[networkController sendMessage:[NSString stringWithFormat:PauseGameFormat, [[self localPlayer] playerNumber]]];
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
	
	// Send the server an "end game" message
	[networkController sendMessage:[NSString stringWithFormat:StopGameFormat, [[self localPlayer] playerNumber]]];
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

#define OperatorPlayerNumber	1

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Determine which item we are looking at based on its action
	SEL itemAction = [item action];
	
	// "New Game" button/menu item
	if (itemAction == @selector(startStopGame:))
	{
		return ([networkController connected] && ([[self localPlayer] playerNumber] == OperatorPlayerNumber));
	}
	
	// "Forfeit" button/menu item
	if (itemAction == @selector(forfeitGame:))
	{
		return (([gameController gameplayState] != gameNotPlaying) && [[self localPlayer] isPlaying]);
	}
	
	// "Pause" button/menu item
	if (itemAction == @selector(pauseResumeGame:))
	{
		return (([gameController gameplayState] != gameNotPlaying) && ([[self localPlayer] playerNumber] == OperatorPlayerNumber));
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

#define NoConnectingMessage	@"noconnecting"
#define WinlistMessage		@"winlist"
#define PlayerNumMessage	(([[networkController currentServer] protocol] == tetrinetProtocol)?@"playernum":@")#)(!@(*3")
#define PlayerJoinedMessage	@"playerjoin"
#define PlayerTeamMessage	@"team"
#define FieldstringMessage	@"f"
#define PlayerLostMessage	@"playerlost"
#define ServerInGameMessage	@"ingame"
#define PauseMessage		@"pause"
#define PlayerLeftMessage	@"playerleave"
#define PLineTextMessage	@"pline"
#define PLineActionMessage	@"plineact"
#define NewGameMessage		(([[networkController currentServer] protocol] == tetrinetProtocol)?@"newgame":@"*******")
#define SpecialUsedMessage	@"sb"
#define GameChatMessage		@"gmsg"
#define LevelUpdateMessage	@"lvl"
#define PlayerWonMessage	@"playerwon"
#define EndGameMessage		@"endgame"

- (void)messageReceived:(NSData*)messageData
{
	// FIXME: debug logging
	NSMutableString* debugString = [NSMutableString string];
	char byte;
	for (NSUInteger i = 0; i < ([messageData length] - 1); i++)
	{
		byte = ((char*)[messageData bytes])[i];
		if (byte > 31)
			[debugString appendFormat:@"%c", byte];
		else
			[debugString appendFormat:@"<\\%02d>", byte];
	}
	NSLog(@"DEBUG:   received incoming message: %@", debugString);
	
	// Naively convert the message to ASCII
	NSString* message = [NSString stringWithCString:[messageData bytes]
							   encoding:NSASCIIStringEncoding];
	
	// Split the message into space-separated tokens
	NSArray* tokens = [message componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Get the first token of the message
	NSString* messageType = [tokens objectAtIndex:0];
	
	NSInteger playerNum;
	
	// Determine the nature of the message
#pragma mark Server Heartbeat Message
	if ([messageType isEqualToString:@""])
	{
		// Send a keepalive message
		[networkController sendMessage:@""];
	}
#pragma mark No Connecting (Error) Message
	else if ([messageType isEqualToString:NoConnectingMessage])
	{
		// Create an error
		message = [[tokens subarrayWithRange:NSMakeRange(1, ([tokens count] - 1))] componentsJoinedByString:@" "];
		NSDictionary* info = [NSDictionary dictionaryWithObject:message
										 forKey:@"errorMessage"];
		NSError* error = [NSError errorWithDomain:iTetNetworkErrorDomain
								 code:iTetNoConnectingError
							   userInfo:info];
		
		// Pass the error to our own error-handling method
		[self connectionError:error];
	}
#pragma mark Winlist Message
	else if ([messageType isEqualToString:WinlistMessage])
	{
		// Hand the remaining tokens to the winlist controller
		[winlistController parseWinlist:[tokens subarrayWithRange:NSMakeRange(1, ([tokens count] - 1))]];
	}
#pragma mark Player Number Message
	else if ([messageType isEqualToString:PlayerNumMessage])
	{
		// Set the local player's number
		[self setLocalPlayerNumber:[[tokens objectAtIndex:1] integerValue]];
	}
#pragma mark Player Joined Message
	else if ([messageType isEqualToString:PlayerJoinedMessage])
	{
		// Add a new player with specified name and number
		NSString* nick = [tokens objectAtIndex:2];
		[self addPlayerWithNumber:[[tokens objectAtIndex:1] integerValue]
				     nickname:nick];
		
		// Add a message to the chat view
		[chatController appendStatusMessage:[NSString stringWithFormat:@"Player %@ has joined the channel", nick]];
	}
#pragma mark Player Team Message
	else if ([messageType isEqualToString:PlayerTeamMessage])
	{
		// Get the player number
		playerNum = [[tokens objectAtIndex:1] integerValue];
		
		// Get the team name (if present)
		NSString* team = @"";
		if ([tokens count] >= 3)
		{
			// Remaining tokens are part of the team name
			team = [[tokens subarrayWithRange:NSMakeRange(2, ([tokens count] - 2))] componentsJoinedByString:@" "];
		}
		
		// Change the player's team name
		[[self playerNumber:playerNum] setTeamName:team];
	}
#pragma mark Fieldstring Message
	else if ([messageType isEqualToString:FieldstringMessage])
	{
		// Get the player number
		playerNum = [[tokens objectAtIndex:1] integerValue];
		
		// If the message includes an update string, apply it to the relevant field
		if ([tokens count] > 2)
		{
			// Get the update string
			NSString* update = [tokens objectAtIndex:2];
			
			// Determine if this is a partial update
			char first = [update cStringUsingEncoding:NSASCIIStringEncoding][0];
			if ((first >= 0x21) && (first <= 0x2F))
			{
				// Update the player's field with a partial update
				[[[self playerNumber:playerNum] field] applyPartialUpdate:update];
			}
			else
			{
				// Give the player a new field created from the fieldstring
				[[self playerNumber:playerNum] setField:[iTetField fieldFromFieldstring:update]];
			}
		}
	}
#pragma mark Player Lost Message
	else if ([messageType isEqualToString:PlayerLostMessage])
	{
		// Get the player number
		playerNum = [[tokens objectAtIndex:1] integerValue];
		
		// Set that player to "not playing"
		[[self playerNumber:playerNum] setPlaying:NO];
		
		// FIXME: anything else?
	}
#pragma mark Server In-Game Message
	else if ([messageType isEqualToString:ServerInGameMessage])
	{
		// Set all players to "playing" (server will send "playerlost" for players not playing)
		for (iTetPlayer* player in [self playerList])
		{
			if (![player isKindOfClass:[iTetLocalPlayer class]])
			{
				[player setPlaying:YES];
				
				// Give the player a clear field (server will send updated fields)
				[player setField:[iTetField field]];
			}
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
	}
#pragma mark Pause Game Message
	else if ([messageType isEqualToString:PauseMessage])
	{
		// Get pause state
		BOOL pauseGame = ([[tokens objectAtIndex:1] integerValue] == 1);
		
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
	}
#pragma mark Player Left Message
	else if ([messageType isEqualToString:PlayerLeftMessage])
	{
		// Get player number
		playerNum = [[tokens objectAtIndex:1] integerValue];
		
		// Add a chat line
		[chatController appendStatusMessage:[NSString stringWithFormat:@"Player %@ has left the channel", [self playerNameForNumber:playerNum]]];
		
		// Remove the player from the game
		[self removePlayerNumber:playerNum];
	}
#pragma mark Partyline Text Message
	else if ([messageType isEqualToString:PLineTextMessage])
	{
		// Check if the message has actual chat text
		if ([tokens count] > 2)
		{
			// Trim the first two tokens off of the message
			NSUInteger startOfChatText = [message rangeOfString:[tokens objectAtIndex:2]].location;
			NSData* chatData = [messageData subdataWithRange:NSMakeRange(startOfChatText, ([messageData length] - startOfChatText))];
			
			// Format the chat text and hand off to the chat controller
			[chatController appendChatLine:[textAttributesController formattedMessageFromData:chatData]
					    fromPlayerName:[self playerNameForNumber:[[tokens objectAtIndex:1] integerValue]]
							action:NO];
		}
	}
#pragma mark Partyline Action Message
	else if ([messageType isEqualToString:PLineActionMessage])
	{
		// Check if the message has actual chat text
		if ([tokens count] > 2)
		{
			// Trim the first two tokens off of the message
			NSUInteger startOfChatText = [message rangeOfString:[tokens objectAtIndex:2]].location;
			NSData* chatData = [messageData subdataWithRange:NSMakeRange(startOfChatText, ([messageData length] - startOfChatText))];
			
			// Format the chat text and hand off to the chat controller
			[chatController appendChatLine:[textAttributesController formattedMessageFromData:chatData]
					    fromPlayerName:[self playerNameForNumber:[[tokens objectAtIndex:1] integerValue]]
							action:YES];
		}
	}
#pragma mark New Game Message
	else if ([messageType isEqualToString:NewGameMessage])
	{
		// All tokens beyond the first (the "newgame" string) are game rules 
		NSArray* rules = [tokens subarrayWithRange:NSMakeRange(1, [tokens count] - 1)];
		
		// Switch to the game view tab, if not already there
		[self switchToGameTab:self];
		
		// Tell the gameController to start the game
		[gameController newGameWithPlayers:[self playerList]
						     rules:[iTetGameRules gameRulesFromArray:rules
											  withGameType:[[networkController currentServer] protocol]]];
		
		// Change the "new game" toolbar item
		[gameButton setLabel:@"End Game"];
		[gameButton setImage:[NSImage imageNamed:@"Stop Red Button"]];
		
		// Change the "new game" menu item
		[gameMenuItem setTitle:@"End Game..."];
		[gameMenuItem setKeyEquivalent:@"e"];
	}
#pragma mark Special Used/Lines Received Message
	else if ([messageType isEqualToString:SpecialUsedMessage])
	{
		// Get the target and sending player numbers
		NSInteger targetNum = [[tokens objectAtIndex:1] integerValue];
		NSInteger senderNum = [[tokens objectAtIndex:3] integerValue];
		
		// Get the special type
		NSString* special = [tokens objectAtIndex:2];
		
		// Translate player numbers into players
		iTetPlayer* sender = nil;
		iTetPlayer* target = nil;
		if (senderNum > 0)
			sender = [self playerNumber:senderNum];
		if (targetNum > 0)
			target = [self playerNumber:targetNum];
		
		// Check if this is a classic-style addline
		if (([special length] > 1) && ([[special substringToIndex:2] isEqualToString:@"cs"]))
		{
			// Get the number of lines
			NSInteger numLines = [[special substringFromIndex:2] integerValue];
			
			// Pass to game controller
			[gameController linesAdded:numLines
						byPlayer:sender];
		}
		// Normal special
		else
		{	
			// Pass to game controller
			[gameController specialUsed:(iTetSpecialType)[special cStringUsingEncoding:NSASCIIStringEncoding][0]
						 byPlayer:sender
						 onPlayer:target];
		}
	}
#pragma mark Game Chat Message
	else if ([messageType isEqualToString:GameChatMessage])
	{
		// Check if the second token is a player's nickname
		NSString* firstWord = [tokens objectAtIndex:1];
		for (iTetPlayer* player in [self playerList])
		{
			if ([firstWord rangeOfString:[player nickname]].location != NSNotFound)
			{
				// Compose the message from the remaining tokens
				message = [[tokens subarrayWithRange:NSMakeRange(2, [tokens count] - 2)] componentsJoinedByString:@" "];
				
				// Add the message to the game chat view
				[gameController appendChatLine:message
						    fromPlayerName:[player nickname]];
				
				return;
			}
		}
		
		// Otherwise, just dump the message on the game chat view
		message = [[tokens subarrayWithRange:NSMakeRange(1, [tokens count] - 1)] componentsJoinedByString:@" "];
		[gameController appendChatLine:message];
	}
#pragma mark Level Update Message
	else if ([messageType isEqualToString:LevelUpdateMessage])
	{
		// Check if this is a request for the client info ("lvl 0 0")
		if (([[tokens objectAtIndex:1] integerValue] == 0) && ([[tokens objectAtIndex:2] integerValue] == 0))
		{
			// Send the client info string
			[networkController sendClientInfo];
		}
		else
		{
			// Otherwise, update the specified player's level
			[[self playerNumber:[[tokens objectAtIndex:1] integerValue]] setLevel:[[tokens objectAtIndex:2] integerValue]];    
		}
	}
#pragma mark Player Won Message
	else if ([messageType isEqualToString:PlayerWonMessage])
	{
		// Get player number
		playerNum = [[tokens objectAtIndex:1] integerValue];
		
		// FIXME: WRITEME: player win message
	}
#pragma mark Game End Message
	else if ([messageType isEqualToString:EndGameMessage])
	{
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
	}
#pragma mark Unknown Message
	else
	{
		// Unknown message type
		NSLog(@"WARNING: Unrecognized message recieved: %@",
			[tokens componentsJoinedByString:@" "]);
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
		
		// Send the player's team name to the server
		if (![[[self localPlayer] teamName] isEqualToString:@""])
		{
			NSString* teamMessage = [NSString stringWithFormat:@"team %d %@",
							 [[self localPlayer] playerNumber],
							 [[self localPlayer] teamName]];
			[networkController sendMessage:teamMessage];
		}
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
	id object = [players objectAtIndex:n];
	if (object == [NSNull null])
			return nil;
		
	return (iTetPlayer*)object;
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
	NSSet* keys = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key rangeOfString:@"remotePlayer"].location != NSNotFound)
	{
		keys = [keys setByAddingObjectsFromSet:[NSSet setWithObjects:@"playerList", @"localPlayer", nil]];
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
