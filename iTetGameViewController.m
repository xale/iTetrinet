//
//  iTetGameViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import "iTetGameViewController.h"

#import "iTetWindowController.h"
#import "iTetPlayersController.h"
#import "iTetPreferencesController.h"

#import "iTetNetworkController.h"
#import "iTetOutgoingMessages.h"

#import "iTetGameRules.h"
#import "iTetLocalPlayer.h"
#import "iTetServerInfo.h"
#import "iTetField.h"
#import "iTetBlock.h"

#import "iTetLocalFieldView.h"
#import "iTetNextBlockView.h"
#import "iTetSpecialsView.h"

#import "iTetKeyActions.h"
#import "NSMutableDictionary+KeyBindings.h"

#import "iTetTextAttributes.h"

#define LOCALPLAYER	[playersController localPlayer]

NSTimeInterval blockFallDelayForLevel(NSInteger level);

@interface iTetGameViewController (Private)

- (void)moveCurrentBlockDown;
- (void)solidifyCurrentBlock;
- (BOOL)checkForLinesCleared;
- (void)moveNextBlockToField;
- (void)useSpecial:(iTetSpecialType)special
		  onTarget:(iTetPlayer*)target
		fromSender:(iTetPlayer*)sender;
- (void)playerLost;

- (void)appendEventDescription:(NSAttributedString*)description;
- (void)clearActions;

- (NSTimer*)nextBlockTimer;
- (NSTimer*)fallTimer;

@end


@implementation iTetGameViewController

- (id)init
{
	gameplayState = gameNotPlaying;
	
	return self;
}

- (void)awakeFromNib
{
	// Bind the game views to the app controller
	// Local field view (field and falling block)
	[localFieldView bind:@"field"
				toObject:playersController
			 withKeyPath:@"localPlayer.field"
				 options:nil];
	[localFieldView bind:@"block"
				toObject:playersController
			 withKeyPath:@"localPlayer.currentBlock"
				 options:nil];
	
	// Next block view
	[nextBlockView bind:@"block"
			   toObject:playersController
			withKeyPath:@"localPlayer.nextBlock"
				options:nil];
	
	// Specials queue view
	[specialsView bind:@"specials"
			  toObject:playersController
		   withKeyPath:@"localPlayer.specialsQueue"
			   options:nil];
	[specialsView bind:@"capacity"
			  toObject:self
		   withKeyPath:@"currentGameRules.specialCapacity"
			   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0]
												   forKey:NSNullPlaceholderBindingOption]];
	
	// Remote field views
	[remoteFieldView1 bind:@"field"
				  toObject:playersController
			   withKeyPath:@"remotePlayer1.field"
				   options:nil];
	[remoteFieldView2 bind:@"field"
				  toObject:playersController
			   withKeyPath:@"remotePlayer2.field"
				   options:nil];
	[remoteFieldView3 bind:@"field"
				  toObject:playersController
			   withKeyPath:@"remotePlayer3.field"
				   options:nil];
	[remoteFieldView4 bind:@"field"
				  toObject:playersController
			   withKeyPath:@"remotePlayer4.field"
				   options:nil];
	[remoteFieldView5 bind:@"field"
				  toObject:playersController
			   withKeyPath:@"remotePlayer5.field"
				   options:nil];
	
	// Clear the chat text
	[self clearChat];
}

- (void)dealloc
{
	[currentGameRules release];
	
	[blockTimer invalidate];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)startStopGame:(id)sender
{	
	// Check if a game is already in progress
	if ([self gameplayState] != gameNotPlaying)
	{
		// Confirm with user before ending game
		// Create a confirmation dialog
		NSAlert* dialog = [[[NSAlert alloc] init] autorelease];
		[dialog setMessageText:@"End Game in Progress?"];
		[dialog setInformativeText:@"Are you sure you want to end the game in progress?"];
		[dialog addButtonWithTitle:@"End Game"];
		[dialog addButtonWithTitle:@"Continue Playing"];
		
		// Run the dialog as a window-modal sheet
		[dialog beginSheetModalForWindow:[windowController window]
						   modalDelegate:self
						  didEndSelector:@selector(stopGameAlertDidEnd:returnCode:contextInfo:)
							 contextInfo:NULL];
	}
	else
	{
		// Start the game
		[networkController sendMessage:[iTetStartStopGameMessage startMessageFromSender:LOCALPLAYER]];
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
	[dialog beginSheetModalForWindow:[windowController window]
					   modalDelegate:self
					  didEndSelector:@selector(forfeitDialogDidEnd:returnCode:contextInfo:)
						 contextInfo:NULL];
}

- (IBAction)pauseResumeGame:(id)sender
{
	// Check if game is already paused
	if ([self gameplayState] == gamePaused)
	{	
		// Send a message asking the server to resume play
		[networkController sendMessage:[iTetPauseResumeGameMessage resumeMessageFromSender:LOCALPLAYER]];
	}
	else
	{
		// Send a message asking the server to pause
		[networkController sendMessage:[iTetPauseResumeGameMessage pauseMessageFromSender:LOCALPLAYER]];
	}
}

- (IBAction)submitChatMessage:(id)sender
{
	// Check that there is a message to send
	NSString* message = [messageField stringValue];
	if ([message length] == 0)
		return;
	
	// Send the message to the server
	[networkController sendMessage:[iTetGameChatMessage messageWithContents:message
																	 sender:LOCALPLAYER]];
	
	// Do not add the message to our chat view; the server will echo it back to us
	
	// Clear the message field
	[messageField setStringValue:@""];
	
	// If there is a game in progress, return first responder status to the field
	if (([self gameplayState] == gamePlaying) && [LOCALPLAYER isPlaying])
		[[windowController window] makeFirstResponder:localFieldView];
}

#pragma mark -
#pragma mark Modal Sheet Callbacks

- (void)stopGameAlertDidEnd:(NSAlert*)dialog
				 returnCode:(NSInteger)returnCode
				contextInfo:(void*)contextInfo
{
	// If the user pressed "continue playing", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// Send the server a "stop game" message
	[networkController sendMessage:[iTetStartStopGameMessage stopMessageFromSender:LOCALPLAYER]];
}

- (void)forfeitDialogDidEnd:(NSAlert*)dialog
				 returnCode:(NSInteger)returnCode
				contextInfo:(void*)contextInfo
{
	// If the user pressed "continue playing", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// Forfeit the current game
	[self playerLost];
}

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Determine which item we are looking at based on its action
	SEL itemAction = [item action];
	
	// Get the current operator player
	iTetPlayer* op = [playersController operatorPlayer];
	
	// "New Game" button/menu item
	if (itemAction == @selector(startStopGame:))
	{
		return (([networkController connectionState] == connected) && [op isEqual:LOCALPLAYER]);
	}
	
	// "Forfeit" button/menu item
	if (itemAction == @selector(forfeitGame:))
	{
		return (([self gameplayState] != gameNotPlaying) && [LOCALPLAYER isPlaying]);
	}
	
	// "Pause" button/menu item
	if (itemAction == @selector(pauseResumeGame:))
	{
		return (([self gameplayState] != gameNotPlaying) && [op isEqual:LOCALPLAYER]);
	}
	
	return YES;
}

#pragma mark -
#pragma mark Chat

- (void)appendChatLine:(NSString*)line
		fromPlayerName:(NSString*)playerName
{
	[self appendChatLine:[NSString stringWithFormat:@"%@: %@", playerName, line]];
}

- (void)appendChatLine:(NSString*)line
{
	// If the chat view is not empty, add a line separator
	if ([[chatView textStorage] length] > 0)
		[[[chatView textStorage] mutableString] appendFormat:@"%C", NSLineSeparatorCharacter];
	
	// Add the line
	[[[chatView textStorage] mutableString] appendString:line];
	
	// Scroll down
	[chatView scrollRangeToVisible:NSMakeRange([[chatView textStorage] length], 0)];
}

- (void)clearChat
{
	[chatView replaceCharactersInRange:NSMakeRange(0, [[chatView textStorage] length])
							withString:@""];
}

#pragma mark -
#pragma mark Controlling Game State

- (void)newGameWithPlayers:(NSArray*)players
				 rulesList:(NSArray*)rulesArray
				  onServer:(iTetServerInfo*)gameServer;
{
	// Clear the list of actions from the last game
	[self clearActions];
	
	// Create the game rules
	[self setCurrentGameRules:[iTetGameRules gameRulesFromArray:rulesArray
												   withGameType:[gameServer protocol]]];
	
	// Set up the players' fields
	for (iTetPlayer* player in players)
	{
		// Set the player's "playing" status
		[player setPlaying:YES];
		
		// Give the player a blank field
		[player setField:[iTetField field]];
		
		// Set the starting level
		[player setLevel:[[self currentGameRules] startingLevel]];
	}
	
	// If there is a starting stack, give the local player a field with garbage
	if ([[self currentGameRules] initialStackHeight] > 0)
	{
		// Create the field
		[LOCALPLAYER setField:[iTetField fieldWithStackHeight:[[self currentGameRules] initialStackHeight]]];
		
		// Send the field to the server
		[self sendFieldstring];
	}
	
	// Create the first block to add to the field
	[LOCALPLAYER setNextBlock:[iTetBlock randomBlockUsingBlockFrequencies:[[self currentGameRules] blockFrequencies]]];
	
	// Move the block to the field
	[self moveNextBlockToField];
	
	// Create a new specials queue for the local player
	[LOCALPLAYER setSpecialsQueue:[NSMutableArray arrayWithCapacity:[[self currentGameRules] specialCapacity]]];
	
	// Reset the local player's cleared lines
	[LOCALPLAYER resetLinesCleared];
	
	// Make sure the field is the first responder
	[[windowController window] makeFirstResponder:localFieldView];
	
	// Set the game state to "playing"
	[self setGameplayState:gamePlaying];
}

- (void)pauseGame
{
	// Set the game state to "paused"
	[self setGameplayState:gamePaused];
	
	// If the local player is still in the game, record the time until the next timer fires
	if ([LOCALPLAYER isPlaying])
	{
		// Record the time until next firing
		timeUntilNextTimerFire = [[blockTimer fireDate] timeIntervalSinceDate:[NSDate date]];
		
		// Record the type of timer
		lastTimerType = [[blockTimer userInfo] intValue];
		
		// Invalidate and nil the timer
		[blockTimer invalidate];
		blockTimer = nil;
	}
}

- (void)resumeGame
{
	// Set the game state to "playing"
	[self setGameplayState:gamePlaying];
	
	// If the local player is in the game, re-create the block timer, and give the field first responder status
	if ([LOCALPLAYER isPlaying])
	{
		// Create a timer with a firing date calculated from the time recorded when the game was paused
		BOOL timerRepeats = (lastTimerType == blockFall);
		blockTimer = [[[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeUntilNextTimerFire]
											   interval:blockFallDelayForLevel([LOCALPLAYER level])
												 target:self
											   selector:@selector(timerFired:)
											   userInfo:[NSNumber numberWithInt:lastTimerType]
												repeats:timerRepeats] autorelease];
		
		// Add the timer to the current run loop
		[[NSRunLoop currentRunLoop] addTimer:blockTimer
									 forMode:NSDefaultRunLoopMode];
		
		// Move first responder to the field
		[[windowController window] makeFirstResponder:localFieldView];
	}
}

- (void)endGame
{
	// Set the game state to "not playing"
	[self setGameplayState:gameNotPlaying];
	
	// Set all players to "not playing"
	for (iTetPlayer* player in [playersController playerList])
		[player setPlaying:NO];
	
	// Invalidate the block timer
	[blockTimer invalidate];
	blockTimer = nil;
	
	// Clear the falling block
	[LOCALPLAYER setCurrentBlock:nil];
}

#pragma mark -
#pragma mark Gameplay Events

- (void)moveCurrentBlockDown
{
	// Attempt to move the block down
	if ([[LOCALPLAYER currentBlock] moveDownOnField:[LOCALPLAYER field]])
	{
		// If the block solidifies, add it to the field
		// Invalidate the old block timer (may already be nil)
		[blockTimer invalidate];
		
		// Add the block to the field
		[self solidifyCurrentBlock];
	}
	// If the block hasn't solidified, check if we need a new fall timer
	else if (blockTimer == nil)
	{
		// Re-create the fall timer
		blockTimer = [self fallTimer];
	}
}

- (void)solidifyCurrentBlock
{
	// Solidify the block
	[[LOCALPLAYER field] solidifyBlock:[LOCALPLAYER currentBlock]];
	
	// Check for cleared lines
	if ([self checkForLinesCleared])
	{
		// Send the updated field to the server
		[self sendFieldstring];
	}
	else
	{
		// Send the field with the new block to the server
		[self sendPartialFieldstring];
	}
	
	// Depending on the protocol, either start the next block immediately, or set a time delay
	if ([[self currentGameRules] gameType] == tetrifastProtocol)
	{
		// Spawn the next block immediately
		[self moveNextBlockToField];
	}
	else
	{
		// Remove the current block
		[LOCALPLAYER setCurrentBlock:nil];
		
		// Set a timer to spawn the next block
		blockTimer = [self nextBlockTimer];
	}
}

- (BOOL)checkForLinesCleared
{
	// Attempt to clear lines on the field
	BOOL linesCleared = NO;
	NSMutableArray* specials = [NSMutableArray array];
	NSInteger numLines = [[LOCALPLAYER field] clearLinesAndRetrieveSpecials:specials];
	while (numLines > 0)
	{
		// Make a note that some lines were cleared
		linesCleared = YES;
		
		// Add the lines to the player's counts
		[LOCALPLAYER addLines:numLines];
		
		// For each line cleared, add a copy of each special in the cleared lines to the player's queue
		for (NSInteger specialsAdded = 0; specialsAdded < numLines; specialsAdded++)
		{
			// Add a copy of each special for each line cleared
			for (NSNumber* special in specials)
			{
				// Check if there is space in the queue
				if ([[LOCALPLAYER specialsQueue] count] >= [[self currentGameRules] specialCapacity])
					goto specialsfull;
				
				// Add to player's queue
				[LOCALPLAYER addSpecialToQueue:special];
			}
		}
		
	specialsfull:
		
		// Check whether to send lines to other players
		if ([currentGameRules classicRules])
		{
			// Determine how many lines to send
			NSInteger linesToSend = 0;
			switch (numLines)
			{
				// For two lines cleared, send one line
				case 2:
					linesToSend = 1;
					break;
					
				// For three lines cleared, send two lines
				case 3:
					linesToSend = 2;
					break;
					
				// For four lines cleared, send four lines
				case 4:
					linesToSend = 4;
					break;
					
				// For one line, send nothing
				default:
					break;
			}
			
			// Send the lines
			if (linesToSend > 0)
				[self sendLines:linesToSend];
		}
		
		// Check for level updates
		NSInteger linesPer = [[self currentGameRules] linesPerLevel];
		while ([LOCALPLAYER linesSinceLastLevel] >= linesPer)
		{
			// Increase the level
			[LOCALPLAYER setLevel:([LOCALPLAYER level] + [[self currentGameRules] levelIncrease])];
			
			// Send a level increase message to the server
			[self sendCurrentLevel];
			
			// Decrement the lines cleared since the last level update
			[LOCALPLAYER setLinesSinceLastLevel:([LOCALPLAYER linesSinceLastLevel] - linesPer)];
		}
		
		// Check whether to add specials to the field
		linesPer = [[self currentGameRules] linesPerSpecial];
		while ([LOCALPLAYER linesSinceLastSpecials] >= linesPer)
		{
			// Add specials
			[[LOCALPLAYER field] addSpecials:[[self currentGameRules] specialsAdded]
							usingFrequencies:[[self currentGameRules] specialFrequencies]];
			
			// Decrement the lines cleared since last specials added
			[LOCALPLAYER setLinesSinceLastSpecials:([LOCALPLAYER linesSinceLastSpecials] - linesPer)];
		}
		
		// Check for additional lines cleared (an unusual occurrence, but still possible)
		[specials removeAllObjects];
		numLines = [[LOCALPLAYER field] clearLinesAndRetrieveSpecials:specials];
	}
	
	return linesCleared;
}

- (void)moveNextBlockToField
{
	iTetBlock* block = [LOCALPLAYER nextBlock];
	
	// Set the block's position to the top of the field
	[block setRowPos:(ITET_FIELD_HEIGHT - ITET_BLOCK_HEIGHT) + [block initialRowOffset]];
	
	// Center the block
	[block setColPos:((ITET_FIELD_WIDTH - ITET_BLOCK_WIDTH)/2) + [block initialColumnOffset]];
	
	// Check if the block can be moved to the field
	if ([[LOCALPLAYER field] blockObstructed:block])
	{
		// Player has lost
		[self playerLost];
		return;
	}
	
	// Transfer the block to the field
	[LOCALPLAYER setCurrentBlock:block];
	
	// Generate a new next block
	[LOCALPLAYER setNextBlock:[iTetBlock randomBlockUsingBlockFrequencies:[[self currentGameRules] blockFrequencies]]];
	
	// Set the fall timer
	blockTimer = [self fallTimer];
}

- (void)useSpecial:(iTetSpecialType)special
		  onTarget:(iTetPlayer*)target
		fromSender:(iTetPlayer*)sender

{
	// Determine the action to take
	switch (special)
	{
		case addLine:
			// Add a line to the field, check for field overflow
			if ([[LOCALPLAYER field] addLines:1 style:specialStyle])
			{
				[self playerLost];
				return;
			}
			break;
			
		case clearLine:
			// Remove the bottom line from the field
			[[LOCALPLAYER field] clearBottomLine];
			break;
			
		case nukeField:
			// Clear the field
			[LOCALPLAYER setField:[iTetField field]];
			break;
			
		case randomClear:
			// Clear random cells from the field
			[[LOCALPLAYER field] clearRandomCells];
			break;
			
		case switchField:
			// If the local player is the target, copy the sender's field
			if ([target playerNumber] == [LOCALPLAYER playerNumber])
				[LOCALPLAYER setField:[[sender field] copy]];
			// If the local player is the sender, copy the target's field
			else
				[LOCALPLAYER setField:[[target field] copy]];
			
			// Safety check: ensure the top rows of the swapped field are clear (prevents the switchfield from being an insta-kill)
			[[LOCALPLAYER field] shiftClearTopRows];
			
			break;
			
		case clearSpecials:
			// Clear all specials from the field
			[[LOCALPLAYER field] removeAllSpecials];
			break;
			
		case gravity:
			// Apply gravity to the field
			[[LOCALPLAYER field] pullCellsDown];
			
			// Lines may be completed after a gravity special, but they don't count toward the player's lines cleared, and specials aren't collected
			[[LOCALPLAYER field] clearLines];
			break;
			
		case quakeField:
			// "Quake" the field
			[[LOCALPLAYER field] randomShiftRows];
			break;
			
		case blockBomb:
			// "Explode" block bomb blocks
			[[LOCALPLAYER field] explodeBlockBombs];
			
			// Block bombs may (very rarely) complete lines; see note at "gravity"
			[[LOCALPLAYER field] clearLines];
			break;
			
		case classicStyle1:
		case classicStyle2:
		case classicStyle4:
			// Add line(s) to the field, check for field overflow
			if ([[LOCALPLAYER field] addLines:[iTetSpecials classicLinesForSpecialType:special] style:classicStyle])
			{
				[self playerLost];
				return;
			}
			break;
			
		default:
			NSLog(@"WARNING: gameViewController -activateSpecial: called with invalid special type: %d", special);
			break;
	}
	
	// Send field changes to the server
	[self sendFieldstring];
}

- (void)playerLost
{
	// Clear the falling block
	[LOCALPLAYER setCurrentBlock:nil];
	
	// Give the player a randomly-filled field
	[LOCALPLAYER setField:[iTetField fieldWithRandomContents]];
	
	// Clear the player's specials queue
	[LOCALPLAYER setSpecialsQueue:[NSMutableArray array]];
	
	// Set the local player's status to "not playing"
	[LOCALPLAYER setPlaying:NO];
	
	// Clear the block timer
	[blockTimer invalidate];
	blockTimer = nil;
	
	// Send a "player lost" message to the server, along with the final field state
	[networkController sendMessage:[iTetPlayerLostMessage messageForPlayer:LOCALPLAYER]];
	[self sendFieldstring];
}

#pragma mark iTetLocalFieldView Event Delegate Methods

- (void)keyPressed:(iTetKeyNamePair*)key
  onLocalFieldView:(iTetLocalFieldView*)fieldView
{
	// Determine whether the pressed key is bound to a game action
	NSMutableDictionary* keyConfig = [[iTetPreferencesController preferencesController] currentKeyConfiguration];
	iTetGameAction action = [keyConfig actionForKey:key];
	
	// If the key is bound to 'game chat,' move first responder to the chat field
	if (action == gameChat)
	{
		// Change first responder
		[[windowController window] makeFirstResponder:messageField];
		return;
	}
	
	// If the game is not in-play, or the local player has lost, ignore any other actions
	if (([self gameplayState] != gamePlaying) || ![LOCALPLAYER isPlaying])
		return;
	
	iTetPlayer* targetPlayer = nil;
	
	// Perform the relevant action
	switch (action)
	{
		case movePieceLeft:
			[[LOCALPLAYER currentBlock] moveHorizontal:moveLeft
											   onField:[LOCALPLAYER field]];
			break;
			
		case movePieceRight:
			[[LOCALPLAYER currentBlock] moveHorizontal:moveRight
											   onField:[LOCALPLAYER field]];
			break;
			
		case rotatePieceCounterclockwise:
			[[LOCALPLAYER currentBlock] rotate:rotateCounterclockwise
									   onField:[LOCALPLAYER field]];
			break;
			
		case rotatePieceClockwise:
			[[LOCALPLAYER currentBlock] rotate:rotateClockwise
									   onField:[LOCALPLAYER field]];
			break;
			
		case movePieceDown:
			// Invalidate the fall timer ("move down" method will reset)
			[blockTimer invalidate];
			blockTimer = nil;
			
			// Move the piece down
			[self moveCurrentBlockDown];
			
			break;
			
		case dropPiece:
			// Invalidate the fall timer
			[blockTimer invalidate];
			blockTimer = nil;
			
			// Move the block down until it stops
			while (![[LOCALPLAYER currentBlock] moveDownOnField:[LOCALPLAYER field]]);
			
			// Solidify the block
			[self solidifyCurrentBlock];
			
			break;
			
		case discardSpecial:
			// Drop the first special from the local player's queue
			if ([[LOCALPLAYER specialsQueue] count] > 0)
				[LOCALPLAYER dequeueNextSpecial];
			break;
			
		case selfSpecial:
			// Send special to self
			targetPlayer = LOCALPLAYER;
			break;
			
			// Attempt to send special to the player in the specified slot
		case specialPlayer1:
			targetPlayer = [playersController playerNumber:1];
			break;
		case specialPlayer2:
			targetPlayer = [playersController playerNumber:2];
			break;
		case specialPlayer3:
			targetPlayer = [playersController playerNumber:3];
			break;
		case specialPlayer4:
			targetPlayer = [playersController playerNumber:4];
			break;
		case specialPlayer5:
			targetPlayer = [playersController playerNumber:5];
			break;
		case specialPlayer6:
			targetPlayer = [playersController playerNumber:6];
			break;
			
		default:
			// Unrecognized key
			break;
	}
	
	// If we have a target and a special to send, send the special
	if ((targetPlayer != nil) && [targetPlayer isPlaying] && ([[LOCALPLAYER specialsQueue] count] > 0))
	{
		[self sendSpecial:[LOCALPLAYER dequeueNextSpecial]
				 toPlayer:targetPlayer];
	}
}

#pragma mark NSControlTextEditingDelegate Methods

- (BOOL)    control:(NSControl *)control
		   textView:(NSTextView *)textView
doCommandBySelector:(SEL)command
{
	// If this is a 'tab' or 'backtab' keypress, do nothing, instead of changing the first responder
	if ([control isEqual:messageField] && ((command == @selector(insertTab:)) || (command == @selector(insertBacktab:))))
		return YES;
	
	// If the this is an 'escape' keypress in the message field, and we are in-game, clear the message field and return first responder status to the game field
	if ([control isEqual:messageField] && (command == @selector(cancelOperation:)) && ([self gameplayState] == gamePlaying) && [LOCALPLAYER isPlaying])
	{
		// Clear the message field
		[messageField setStringValue:@""];
		
		// Return first responder to the game field
		[[windowController window] makeFirstResponder:localFieldView];
	}
	
	return NO;
}

#pragma mark -
#pragma mark Client-to-Server Events

- (void)sendFieldstring
{	
	// Send the string for the local player's field to the server
	[networkController sendMessage:[iTetFieldstringMessage fieldMessageForPlayer:LOCALPLAYER]];
}

- (void)sendPartialFieldstring
{
	// Send the last partial update on the local player's field to the server
	[networkController sendMessage:[iTetFieldstringMessage partialUpdateMessageForPlayer:LOCALPLAYER]];
}

- (void)sendCurrentLevel
{
	// Send the local player's level to the server
	[networkController sendMessage:[iTetLevelUpdateMessage messageWithUpdateForPlayer:LOCALPLAYER]];
}

- (void)sendSpecial:(iTetSpecialType)special
		   toPlayer:(iTetPlayer*)target
{	
	// Send a message to the server
	iTetSpecialMessage* message = [iTetSpecialMessage messageWithSpecialType:special
																	  sender:LOCALPLAYER
																	  target:target];
	[networkController sendMessage:message];
	
	// Perform and record the action
	[self specialUsed:special
			 byPlayer:LOCALPLAYER
			 onPlayer:target];
}

- (void)sendLines:(NSInteger)lines
{	
	// Send the message to the server
	iTetSpecialMessage* message = [iTetSpecialMessage messageWithClassicStyleLines:lines
																			sender:LOCALPLAYER];
	[networkController sendMessage:message];
	
	// Perform and record the action
	[self specialUsed:[message specialType]
			 byPlayer:LOCALPLAYER
			 onPlayer:nil];
}

#pragma mark -
#pragma mark Server-to-Client Events

- (void)fieldstringReceived:(NSString*)fieldstring
				  forPlayer:(iTetPlayer*)player
			  partialUpdate:(BOOL)isPartial;
{
	if (isPartial)
	{
		// Update the player's field with a partial update
		[[player field] applyPartialUpdate:fieldstring];
	}
	else
	{
		// Give the player a new field created from the fieldstring
		[player setField:[iTetField fieldFromFieldstring:fieldstring]];
	}
}

NSString* const iTetSpecialEventDescriptionFormat =		@"%@ used on %@ by %@";
NSString* const iTetLinesAddedEventDescriptionFormat =	@"%@ added to %@ by %@";
NSString* const iTetOneLineAddedFormat =				@"1 Line";
NSString* const iTetMultipleLinesAddedFormat =			@"%d Lines";
NSString* const iTetNilSenderNamePlaceholder =			@"Server";
NSString* const iTetNilTargetNamePlaceholder =			@"All";

#define iTetEventBackgroundColorFraction	(0.15)

- (void)specialUsed:(iTetSpecialType)special
		   byPlayer:(iTetPlayer*)sender
		   onPlayer:(iTetPlayer*)target
{
	// Check if this action affects the local player
	BOOL localPlayerAffected = (((target == nil) && ((sender == nil) || ([sender playerNumber] != [LOCALPLAYER playerNumber]))) ||
								((target != nil) && ([target playerNumber] == [LOCALPLAYER playerNumber])) ||
								((sender != nil) && ([sender playerNumber] == [LOCALPLAYER playerNumber]) && (special == switchField)));
	
	// Perform the action, if applicable
	if (localPlayerAffected)
	{
		[self useSpecial:special
				onTarget:target
			  fromSender:sender];
	}
	
	// Add a description of the event to the list of actions
	NSString* senderName;
	NSString* targetName;
	NSMutableAttributedString* desc;
	NSColor* textColor;
	NSRange attributeRange;
	
	// Determine the target player's name
	if (target == nil)
		targetName = iTetNilTargetNamePlaceholder;
	else
		targetName = [target nickname];
	
	// Determine the sender player's name
	if (sender == nil)
		senderName = iTetNilSenderNamePlaceholder;
	else
		senderName = [sender nickname];
	
	// Determine if the special is a classic-style line add
	NSInteger numLinesAdded = [iTetSpecials classicLinesForSpecialType:special];
	if (numLinesAdded > 0)
	{
		// Describe the number of lines added
		NSString* linesDesc;
		if (numLinesAdded > 1)
			linesDesc = [NSString stringWithFormat:iTetMultipleLinesAddedFormat, numLinesAdded];
		else
			linesDesc = iTetOneLineAddedFormat;
		
		// Create the description string
		desc = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:iTetLinesAddedEventDescriptionFormat, linesDesc, targetName, senderName]
													   attributes:[iTetTextAttributes defaultGameActionsTextAttributes]] autorelease];
		
		// Find the highlight range and color
		attributeRange = [[desc string] rangeOfString:linesDesc];
		textColor = [iTetTextAttributes linesAddedDescriptionTextColor];
	}
	else
	{
		// Get the name of the special used
		NSString* specialName = [iTetSpecials nameForSpecialType:special];
		
		// Create the description string
		desc = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:iTetSpecialEventDescriptionFormat, specialName, targetName, senderName]
													   attributes:[iTetTextAttributes defaultGameActionsTextAttributes]] autorelease];
		
		// Find the highlight range and color
		attributeRange = [[desc string] rangeOfString:specialName];
		if ([iTetSpecials specialIsPositive:special])
			textColor = [iTetTextAttributes goodSpecialDescriptionTextColor];
		else
			textColor = [iTetTextAttributes badSpecialDescriptionTextColor];
	}
	
	// Apply bold and color to the chosen highlight range
	[desc applyFontTraits:NSBoldFontMask
					range:attributeRange];
	[desc addAttributes:[NSDictionary dictionaryWithObject:textColor
													forKey:NSForegroundColorAttributeName]
				  range:attributeRange];
	
	// Bold the target and sender names
	[desc applyFontTraits:NSBoldFontMask
					range:[[desc string] rangeOfString:targetName]];
	[desc applyFontTraits:NSBoldFontMask
					range:[[desc string] rangeOfString:senderName
											   options:NSBackwardsSearch]];
	
	// If the local player was affected, add a background color
	if (localPlayerAffected)
	{
		[desc addAttributes:[NSDictionary dictionaryWithObject:[[NSColor whiteColor] blendedColorWithFraction:iTetEventBackgroundColorFraction
																									  ofColor:textColor]
														forKey:NSBackgroundColorAttributeName]
					  range:NSMakeRange(0, [desc length])];
	}
	
	// Record the event
	[self appendEventDescription:desc];
}

#pragma mark -
#pragma mark Event Descriptions

- (void)appendEventDescription:(NSAttributedString*)description
{
	// Add the line
	[[actionListView textStorage] appendAttributedString:description];
	
	// Add a line separator
	[[[actionListView textStorage] mutableString] appendFormat:@"%C", NSParagraphSeparatorCharacter];
	
	// Scroll the view to ensure the line is visible
	[actionListView scrollRangeToVisible:NSMakeRange([[actionListView textStorage] length], 0)];
}

- (void)clearActions
{
	[actionListView replaceCharactersInRange:NSMakeRange(0, [[actionListView textStorage] length])
								  withString:@""];
}

#pragma mark -
#pragma mark Timers

#define TETRINET_NEXT_BLOCK_DELAY	1.0

- (NSTimer*)nextBlockTimer
{	
	// Start the timer to spawn the next block
	return [NSTimer scheduledTimerWithTimeInterval:TETRINET_NEXT_BLOCK_DELAY
											target:self
										  selector:@selector(timerFired:)
										  userInfo:[NSNumber numberWithInt:nextBlock]
										   repeats:NO];
}

- (NSTimer*)fallTimer
{	
	// Start the timer to move the block down
	return [NSTimer scheduledTimerWithTimeInterval:blockFallDelayForLevel([LOCALPLAYER level])
											target:self
										  selector:@selector(timerFired:)
										  userInfo:[NSNumber numberWithInt:blockFall]
										   repeats:YES];
}

- (void)timerFired:(NSTimer*)timer
{
	switch ([[timer userInfo] intValue])
	{
		case nextBlock:
			[self moveNextBlockToField];
			break;
			
		case blockFall:
			[self moveCurrentBlockDown];
			break;
	}
}

#define ITET_MAX_DELAY_TIME				(1.005)
#define ITET_DELAY_REDUCTION_PER_LEVEL	(0.01)
#define ITET_MIN_DELAY_TIME				(0.005)

NSTimeInterval blockFallDelayForLevel(NSInteger level)
{
	NSTimeInterval time = ITET_MAX_DELAY_TIME - (level * ITET_DELAY_REDUCTION_PER_LEVEL);
	
	if (time < ITET_MIN_DELAY_TIME)
		return ITET_MIN_DELAY_TIME;
	
	return time;
}

#pragma mark -
#pragma mark Accessors

@synthesize currentGameRules;

- (void)setGameplayState:(iTetGameplayState)newState
{
	if (gameplayState == newState)
		return;
	
	switch (newState)
	{
		case gameNotPlaying:
			// Reset the "end game" menu and toolbar items
			[gameMenuItem setTitle:@"New Game"];
			[gameMenuItem setKeyEquivalent:@"n"];
			[gameButton setLabel:@"New Game"];
			[gameButton setImage:[NSImage imageNamed:@"Play Green Button"]];
			
			// If the game was paused, reset the "resume" menu and toolbar items
			if (gameplayState == gamePaused)
			{
				[pauseMenuItem setTitle:@"Pause Game"];
				[pauseButton setLabel:@"Pause Game"];
				[pauseButton setImage:[NSImage imageNamed:@"Pause Blue Button"]];
			}
			
			break;
		
		case gamePaused:
			// Change the "pause" toolbar and menu items to "resume" items
			[pauseMenuItem setTitle:@"Resume Game"];
			[pauseButton setLabel:@"Resume Game"];
			[pauseButton setImage:[NSImage imageNamed:@"Play Blue Button"]];
			
			break;
			
		case gamePlaying:
			// Change the "new game" menu and toolbar items to "end game" items
			[gameMenuItem setTitle:@"End Game..."];
			[gameMenuItem setKeyEquivalent:@"e"];
			[gameButton setLabel:@"End Game"];
			[gameButton setImage:[NSImage imageNamed:@"Stop Red Button"]];
			
			// If the game was paused, reset the "resume" menu and toolbar items
			if (gameplayState == gamePaused)
			{
				[pauseMenuItem setTitle:@"Pause Game"];
				[pauseButton setLabel:@"Pause Game"];
				[pauseButton setImage:[NSImage imageNamed:@"Pause Blue Button"]];
			}
			
			break;
	}
	
	[self willChangeValueForKey:@"gameplayState"];
	gameplayState = newState;
	[self didChangeValueForKey:@"gameplayState"];
}
@synthesize gameplayState;

- (BOOL)gameInProgress
{
	return ([self gameplayState] == gamePlaying) || ([self gameplayState] == gamePaused);
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	if ([key isEqualToString:@"gameplayState"])
		return NO;
	
	return [super automaticallyNotifiesObserversForKey:key];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	NSSet* keys = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"gameInProgress"])
		keys = [keys setByAddingObject:@"gameplayState"];
	
	return keys;
}

@end
