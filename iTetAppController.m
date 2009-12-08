//
//  iTetAppController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import "iTetAppController.h"
#import "iTetNetworkController.h"
#import "iTetPreferencesController.h"
#import "iTetChatViewController.h"
#import "iTetGameViewController.h"
#import "iTetServerInfo.h"
#import "iTetLocalPlayer.h"
#import "iTetGameRules.h"
#import "iTetPreferencesWindowController.h"
#import "iTetProtocolTransformer.h"
#import "iTetSpecialNameTransformer.h"

@implementation iTetAppController

+ (void)initialize
{
	// Register value transformers
	iTetProtocolTransformer* pt = [[[iTetProtocolTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:pt
						  forName:@"TetrinetProtocolTransformer"];
	pt = [[[iTetSpecialNameTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:pt
						  forName:@"TetrinetSpecialNameTransformer"];
	
	// Seed random number generator
	srandom(time(NULL));
}

- (id)init
{
	// Create the network controller, with this object as the delegate for
	// messages recieved from the server
	networkController = [[iTetNetworkController alloc] initWithDelegate:self];
	
	return self;
}

- (void)awakeFromNib
{
	[window setAutorecalculatesContentBorderThickness:NO
								forEdge:NSMinYEdge];
	[window setContentBorderThickness:25
					  forEdge:NSMinYEdge];
}

- (void)dealloc
{	
	[networkController release];
	[prefsWindowController release];
	
	[self removeAllPlayers];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)openCloseConnection:(id)sender
{
	// If there is already a connection open, disconnect
	if ([networkController connected])
	{
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
	NSAlert* dialog = [[NSAlert alloc] init];
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
				   contextInfo:nil];
}

NSString* const StartGameFormat =	@"startgame 1 %d";
NSString* const StopGameFormat =	@"startgame 0 %d";

- (IBAction)startStopGame:(id)sender
{	
	// Check if a game is already in progress
	if ([gameController gameInProgress])
	{
		// Confirm with user before ending game
		// Create a confirmation dialog
		NSAlert* dialog = [[NSAlert alloc] init];
		[dialog setMessageText:@"End Game in Progress?"];
		[dialog setInformativeText:@"Are you sure you want to end the game in progress?"];
		[dialog addButtonWithTitle:@"Continue Playing"];
		[dialog addButtonWithTitle:@"End Game"];
		
		// Run the dialog as a window-modal sheet
		[dialog beginSheetModalForWindow:window
					 modalDelegate:self
					didEndSelector:@selector(stopGameAlertDidEnd:returnCode:contextInfo:)
					   contextInfo:nil];
	}
	else
	{
		// Start the game
		[networkController sendMessage:
		 [NSString stringWithFormat:StartGameFormat, [[self localPlayer] playerNumber]]];
	}
}

// FIXME: not sure about these:
NSString* const PauseGameFormat =	@"pause 1 %d";
NSString* const ResumeGameFormat =	@"pause 0 %d";

- (IBAction)pauseResumeGame:(id)sender
{
	// Check if game is already paused
	if ([gameController gamePaused])
	{
		// Unpause the game
		[gameController setGamePaused:NO];
		
		// Send a message asking the server to resume play
		[networkController sendMessage:
		 [NSString stringWithFormat:ResumeGameFormat, [[self localPlayer] playerNumber]]];
		
		// Change the "resume" button back into pause button
		[pauseButton setLabel:@"Pause Game"];
		[pauseButton setImage:[NSImage imageNamed:@"Pause Blue Button"]];
		
		// Change the menu item
		[pauseMenuItem setTitle:@"Pause Game"];
	}
	else
	{
		// Pause the game
		[gameController setGamePaused:YES];
		
		// Send a message asking the server to pause
		[networkController sendMessage:
		 [NSString stringWithFormat:PauseGameFormat, [[self localPlayer] playerNumber]]];
		
		// Change the pause button to a "resume" button
		[pauseButton setLabel:@"Resume Game"];
		[pauseButton setImage:[NSImage imageNamed:@"Play Blue Button"]];
		
		// Change the menu item
		[pauseMenuItem setTitle:@"Resume Game"];
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

#pragma mark -
#pragma mark Modal Sheet Callbacks

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
	
	// Start the connection timer
	connectionTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
									   target:self
									 selector:@selector(connectionTimedOut:)
									 userInfo:nil
									  repeats:NO];
}

- (void)stopGameAlertDidEnd:(NSAlert*)dialog
		     returnCode:(NSInteger)returnCode
		    contextInfo:(void*)contextInfo
{
	// If the user pressed "continue playing", do nothing
	if (returnCode == NSAlertFirstButtonReturn)
		return;
	
	// Otherwise, stop the game in progress
	[gameController endGame];
	
	// Send the server an "end game" message
	[networkController sendMessage:
	 [NSString stringWithFormat:StopGameFormat, [[self localPlayer] playerNumber]]];
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
		if ([networkController connected] && ([[self localPlayer] playerNumber] == OperatorPlayerNumber))
			return YES;
		
		return NO;
	}
	
	// "Pause" button/menu item
	if (itemAction == @selector(pauseResumeGame:))
	{
		// FIXME: can non-op players pause the game?
		if ([gameController gameInProgress] && ([[self localPlayer] playerNumber] == OperatorPlayerNumber))
			return YES;
		
		return NO;
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
	
	// Change the connection toolbar item
	[connectionButton setLabel:@"Disconnect"];
	[connectionButton setImage:[NSImage imageNamed:@"Eject Blue Button"]];
	
	// Change the connection menu item
	[connectionMenuItem setTitle:@"Disconnect from Server"];
	[connectionMenuItem setKeyEquivalent:@"w"];
	
	// Clear the chat view
	[chatController clearChat];
	[chatController appendChatLine:@"* Connection Opened *"];
}

- (void)connectionClosed
{
	[self removeAllPlayers];
	
	// Change the connection toolbar item
	[connectionButton setLabel:@"Connect"];
	[connectionButton setImage:[NSImage imageNamed:@"Network"]];
	
	// Change the connection menu item
	[connectionMenuItem setTitle:@"Connect to Server..."];
	[connectionMenuItem setKeyEquivalent:@"o"];
	
	[chatController appendChatLine:@"* Connection Closed *"];
}

- (void)connectionError:(NSError*)error
{
	NSAlert* alert = [[NSAlert alloc] init];
	
	// If we were attempting to connect, invalidate the timeout timer
	if (connectionTimer != nil)
	{
		[connectionTimer invalidate];
		connectionTimer = nil;
		
		[alert setMessageText:@"Error connecting to server"];
	}
	else
	{
		[alert setMessageText:@"Connection error"];
	}
	
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
	
	[alert setInformativeText:errorText];
	[alert addButtonWithTitle:@"Okay"];
	
	[alert beginSheetModalForWindow:window
				modalDelegate:self
			     didEndSelector:@selector(connectionErrorAlertEnded:returnCode:contextInfo:)
				  contextInfo:NULL];
}

- (void)connectionErrorAlertEnded:(NSAlert*)alert
			     returnCode:(int)returnCode
			    contextInfo:(void*)contextInfo
{
	// Reset the connection button
	[connectionButton setLabel:@"Connect"];
	[connectionButton setImage:[NSImage imageNamed:@"Network"]];
}

#define NoConnectingMessage	@"noconnecting"
#define WinlistMessage		@"winlist"
#define PlayerNumMessage	((protocol == tetrinetProtocol)?@"playernum":@")#)(!@(*3")
#define PlayerJoinedMessage	@"playerjoin"
#define PlayerTeamMessage	@"team"
#define FieldStateMessage	@"f"
#define PlayerLostMessage	@"playerlost"
#define ServerInGameMessage	@"ingame"
#define PauseMessage		@"pause"
#define PlayerLeftMessage	@"playerleave"
#define PLineTextMessage	@"pline"
#define PLineActionMessage	@"plineact"
#define NewGameMessage		((protocol == tetrinetProtocol)?@"newgame":@"*******")
#define SpecialUsedMessage	@"sb"
#define GameMessageMessage	@"gmsg"
#define LevelUpdateMessage	@"lvl"
#define PlayerWonMessage	@"playerwon"
#define EndGameMessage		@"endgame"

- (void)messageRecieved:(NSString*)message
{
	NSLog(@"DEBUG: parsing message: %@", message);
	
	// Split the message into space-separated tokens
	NSArray* tokens = [message componentsSeparatedByCharactersInSet:
				 [NSCharacterSet whitespaceCharacterSet]];
	
	// Get the first token of the message
	NSString* messageType = [tokens objectAtIndex:0];
	
	// Check which protocol we are using
	iTetProtocolType protocol = [[networkController currentServer] protocol];
	
	// Determine the nature of the message
	// Server "heartbeat"
	if ([messageType isEqualToString:@""])
	{
		// Ignore
	}
	// "No connecting" (error)
	else if ([messageType isEqualToString:NoConnectingMessage])
	{
		// Create an error
		NSString* errorMessage = [[tokens subarrayWithRange:NSMakeRange(1, ([tokens count] - 1))]
						  componentsJoinedByString:@" "];
		NSDictionary* info = [NSDictionary dictionaryWithObject:errorMessage
										 forKey:@"errorMessage"];
		NSError* error = [NSError errorWithDomain:iTetNetworkErrorDomain
								 code:iTetNoConnectingError
							   userInfo:info];
		
		// Pass the error to our own error-handling method
		[self connectionError:error];
	}
	// Winlist
	else if ([messageType isEqualToString:WinlistMessage])
	{
		// FIXME: debug logging
		NSLog(@"DEBUG: MESSAGE: winlist received");
		
		// FIXME: WRITEME: Winlist parsing
	}
	// Player number
	else if ([messageType isEqualToString:PlayerNumMessage])
	{
		// Get the number
		int playerNum = [[tokens objectAtIndex:1] intValue];
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: player number received: %d", playerNum);
		
		[self setLocalPlayerNumber:playerNum];
	}
	// Player joined
	else if ([messageType isEqualToString:PlayerJoinedMessage])
	{
		// Get the player number and nickname
		int playerNum = [[tokens objectAtIndex:1] intValue];
		NSString* nick = [tokens objectAtIndex:2];
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: player joined: #%d; nick: %@", playerNum, nick);
		
		[self addPlayerWithNumber:playerNum
				     nickname:nick];
		
		// Add a message to the chat view
		[chatController appendChatLine:
		 [NSString stringWithFormat:@"* Player %@ has joined the channel *", nick]];
	}
	// Player's team
	else if ([messageType isEqualToString:PlayerTeamMessage])
	{
		// Get the player number
		int playerNum = [[tokens objectAtIndex:1] intValue];
		
		// Get the team name (if present)
		NSString* team = @"";
		if ([tokens count] >= 3)
		{
			team = [[tokens subarrayWithRange:NSMakeRange(2, [tokens count])] 
				  componentsJoinedByString:@" "];
		}
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: player number %d joined team '%@'", playerNum, team);
		
		[self setTeamName:team
		  forPlayerNumber:playerNum];
	}
	// Fieldstate
	else if ([messageType isEqualToString:FieldStateMessage])
	{
		// Get the player number
		int playerNum = [[tokens objectAtIndex:1] intValue];
		
		// Get the update string
		NSString* update = [tokens objectAtIndex:2];
		
		// Determine if this is a partial update
		BOOL partial = NO;
		char first = [update cStringUsingEncoding:NSASCIIStringEncoding][0];
		if ((first >= 0x21) && (first <= 0x2F))
		{
			// Partial update
			partial = YES;
			update = [update substringFromIndex:1];
		}
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: fieldstate update for player number %d:", playerNum);
		NSLog(@"       MESSAGE: update: %@", update);
		NSLog(@"       MESSAGE: partial: %d", partial);
		if (partial)
			NSLog(@"       MESSAGE: blockType: %c", first);
		
		// FIXME: WRITEME: fieldstate updates
	}
	// Player lost
	else if ([messageType isEqualToString:PlayerLostMessage])
	{
		// Get the player number
		int playerNum = [[tokens objectAtIndex:1] intValue];
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: player number %d lost", playerNum);
		
		// FIXME: WRITEME: player lost
	}
	// Server "in-game"
	else if ([messageType isEqualToString:ServerInGameMessage])
	{
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: server is in-game");
		
		// FIXME: WRITEME: server in-game on join
	}
	// Pause game
	else if ([messageType isEqualToString:PauseMessage])
	{
		// Get pause state
		BOOL paused = ([[tokens objectAtIndex:1] intValue] == 1);
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: game pause state: %d", paused);
		
		// FIXME: WRITEME: pause game
	}
	// Player left
	else if ([messageType isEqualToString:PlayerLeftMessage])
	{
		// Get player number
		int playerNum = [[tokens objectAtIndex:1] intValue];
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: player number %d left game", playerNum);
		
		// Add a chat line
		[chatController appendChatLine:
		 [NSString stringWithFormat:@"* Player %@ has left the channel *",
		  [self playerNameForNumber:playerNum]]];
		
		[self removePlayerNumber:playerNum];
	}
	// Partyline message
	else if ([messageType isEqualToString:PLineTextMessage])
	{
		// Get the player nickname
		NSString* nick = [self playerNameForNumber:[[tokens objectAtIndex:1] intValue]];
		
		// Create the message from all but the first two tokens
		NSString* message = [[tokens subarrayWithRange:NSMakeRange(2, ([tokens count] - 2))]
					  componentsJoinedByString:@" "];
		
		// Hand the message off to the chat controller
		[chatController appendChatLine:message
				    fromPlayerName:nick
						action:NO];
	}
	// Partyline action message
	else if ([messageType isEqualToString:PLineActionMessage])
	{
		// Get the player nickname
		NSString* nick = [self playerNameForNumber:[[tokens objectAtIndex:1] intValue]];
		
		// Create the action from all but the first two tokens
		NSString* action = [[tokens subarrayWithRange:NSMakeRange(2, ([tokens count] - 2))]
					  componentsJoinedByString:@" "];
		
		// Hand the action off to the chat controller
		[chatController appendChatLine:action
				    fromPlayerName:nick
						action:YES];
	}
	// New game
	else if ([messageType isEqualToString:NewGameMessage])
	{
		// All tokens beyond the first (the "newgame" string) are game rules 
		NSArray* rules = [tokens subarrayWithRange:NSMakeRange(1, [tokens count] - 1)];
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: new game with rules string: %@", rules);
		
		// Tell the gameController to start the game
		[gameController newGameWithPlayers:[self playerList]
						     rules:[iTetGameRules gameRulesFromArray:rules]];
		
		// Change the "new game" toolbar item
		[gameButton setLabel:@"End Game"];
		[gameButton setImage:[NSImage imageNamed:@"Stop Red Button"]];
		
		// Change the "new game" menu item
		[gameMenuItem setTitle:@"End Game..."];
		[gameMenuItem setKeyEquivalent:@"e"];
	}
	// Special used / lines sent
	else if ([messageType isEqualToString:SpecialUsedMessage])
	{
		// Get the target and sending player numbers
		int targetNum = [[tokens objectAtIndex:1] intValue];
		int senderNum = [[tokens objectAtIndex:3] intValue];
		
		// Get the special type
		NSString* special = [tokens objectAtIndex:2];
		
		// Translate player numbers into players
		iTetPlayer* sender = nil;
		iTetPlayer* target = nil;
		if (senderNum > 0)
			sender = players[(senderNum - 1)];
		if (targetNum > 0)
			target = players[(targetNum - 1)];
		
		// Check if this is a classic-style addline
		if (([special length] > 1) && ([[special substringToIndex:2] isEqualToString:@"cs"]))
		{
			// Get the number of lines
			int numLines = [[special substringFromIndex:2] intValue];
			
			// Pass to game controller
			[gameController linesAdded:numLines
						byPlayer:sender];
		}
		// Normal special
		else
		{	
			// Pass to game controller
			[gameController specialUsed:(iTetSpecialType)[special intValue]
						 byPlayer:sender
						 onPlayer:target];
		}
	}
	// Game messages
	else if ([messageType isEqualToString:GameMessageMessage])
	{
		NSString* message = [tokens componentsJoinedByString:@" "];
		
		// FIXME: Debug logging
		NSLog(@"DEBUG: MESSAGE: game-message receieved: %@", message);
		
		// FIXME: WRITEME: game-message recieved
	}
	// Level update
	else if ([messageType isEqualToString:LevelUpdateMessage])
	{
		// Get player and level number
		int playerNum = [[tokens objectAtIndex:1] intValue];
		int levelNum = [[tokens objectAtIndex:2] intValue];
		
		// FIXME: debug logging
		NSLog(@"DEBUG: MESSAGE: player number %d reached level %d", playerNum, levelNum);
		
		// FIXME: WRITEME: level update
	}
	// Player won
	else if ([messageType isEqualToString:PlayerWonMessage])
	{
		// Get player number
		int playerNum = [[tokens objectAtIndex:1] intValue];
		
		// FIXME: debug logging
		NSLog(@"DEBUG: MESSAGE: player number %d has won the game", playerNum);
		
		// FIXME: WRITEME: player win message
	}
	// Game ended
	else if ([messageType isEqualToString:EndGameMessage])
	{
		// FIXME: debug logging
		NSLog(@"DEBUG: MESSAGE: game ended");
		
		// FIXME: WRITEME: game over message
	}
	else
	{
		// Unknown message type
		NSLog(@"WARNING: Unrecognized message recieved: %@",
			[tokens componentsJoinedByString:@" "]);
	}
}

#pragma mark -
#pragma mark Players

#define iTetCheckPlayerNumber(n) NSParameterAssert(((n) > 0) && ((n) <= ITET_MAX_PLAYERS))

- (void)setLocalPlayerNumber:(int)number
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Check that the assigned slot is not already occupied
	if (players[(number - 1)] != nil)
	{
		NSLog(@"WARNING: local player assigned to occupied player slot");
		[gameController removeBoardAssignmentForPlayer:players[(number -1)]];
		[players[(number - 1)] release];
		playerCount--;
	}
	
	// Check if our player already exists; if so, this is a move operation
	if ([self localPlayer] != nil)
	{
		// nil the old location in the players array
		players[([[self localPlayer] playerNumber] - 1)] = nil;
		
		// Change the local player's number
		[[self localPlayer] setPlayerNumber:number];
		
		// Move to the new location in the players array
		players[(number - 1)] = (iTetPlayer*)[self localPlayer];
		
		// No need to notify game controller; board assignment will not change
	}
	else
	{
		// Create the local player
		[self setLocalPlayer:[[iTetLocalPlayer alloc] initWithNickname:[[networkController currentServer] nickname]
											  number:number
											teamName:[[networkController currentServer] playerTeam]]];
		
		// Place the player in the players array
		players[(number - 1)] = localPlayer;
		
		// Update player count
		playerCount++;
		
		// Assign the local board to this player
		[gameController assignBoardToPlayer:localPlayer];
		
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

- (void)addPlayerWithNumber:(int)number
			 nickname:(NSString*)nick
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Check that the slot is not already occupied
	if (players[(number - 1)] != nil)
	{
		NSLog(@"WARNING: new player assigned to occupied player slot");
		[gameController removeBoardAssignmentForPlayer:players[(number - 1)]];
		[players[(number - 1)] release];
		playerCount--;
	}
	
	// Create the new player
	players[(number - 1)] = [[iTetPlayer alloc] initWithNickname:nick
										number:number];
	
	// Update player count
	playerCount++;
	
	[self didChangeValueForKey:@"playerList"];
	
	// Assign a board for the new player
	[gameController assignBoardToPlayer:players[(number - 1)]];
}

- (void)setTeamName:(NSString*)team
    forPlayerNumber:(int)number
{
	// Sanity checks
	iTetCheckPlayerNumber(number);
	if (players[(number - 1)] == nil)
	{
		NSLog(@"WARNING: attempt to assign team name to player in empty player slot");
		return;
	}
	
	[self willChangeValueForKey:@"playerList"];
	
	// Assign the team name
	[players[(number - 1)] setTeamName:team];
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)removePlayerNumber:(int)number
{
	// Sanity checks
	iTetCheckPlayerNumber(number);
	if (players[(number - 1)] == nil)
	{
		NSLog(@"WARNING: attempt to remove player in empty player slot");
		return;
	}
	
	// Remove the player's board assignment
	[gameController removeBoardAssignmentForPlayer:players[(number - 1)]];
	
	[self willChangeValueForKey:@"playerList"];
	
	// Remove the player
	[players[(number - 1)] release];
	players[(number - 1)] = nil;
	
	// Update player count
	playerCount--;
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)removeAllPlayers
{
	[self willChangeValueForKey:@"playerList"];
	
	// Remove all players
	for (int i = 0; i < ITET_MAX_PLAYERS; i++)
	{
		if (players[i] != nil)
		{
			[gameController removeBoardAssignmentForPlayer:players[i]];
			[players[i] release];
			players[i] = nil;
		}
	}
	
	// nil the local player pointer (released with the others)
	[self setLocalPlayer:nil];
	
	// Reset the player count
	playerCount = 0;
	
	[self didChangeValueForKey:@"playerList"];
}

#pragma mark -
#pragma mark Connection Timeout Callback

- (void)connectionTimedOut:(NSTimer*)timer
{
	// Tell the network controller to abort the connection
	[networkController disconnect];
	
	// Nil the timer
	connectionTimer = nil;
	
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
		    returnCode:(int)returnCode
		   contextInfo:(void*)contextInfo
{
	// Reset the connection button
	[connectionButton setLabel:@"Connect"];
	[connectionButton setImage:[NSImage imageNamed:@"Network"]];
}

#pragma mark -
#pragma mark Accessors

- (NSArray*)playerList
{
	NSMutableArray* list = [NSMutableArray arrayWithCapacity:playerCount];
	for (int i = 0; i < ITET_MAX_PLAYERS; i++)
	{
		if (players[i] != nil)
			[list addObject:players[i]];
	}
	
	return [NSArray arrayWithArray:list];
}

@synthesize localPlayer;

- (NSString*)playerNameForNumber:(int)number
{
	if (number == 0)
		return @"SERVER";
	else
		return [players[(number - 1)] nickname];
}

@synthesize networkController;

- (iTetPreferencesController*)preferencesController
{
	return [iTetPreferencesController preferencesController];
}


@end
