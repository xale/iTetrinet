//
//  iTetGameViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import "iTetGameViewController.h"
#import "iTetAppController.h"
#import "iTetPreferencesController.h"
#import "iTetLocalPlayer.h"
#import "iTetLocalFieldView.h"
#import "iTetNextBlockView.h"
#import "iTetSpecialsView.h"
#import "iTetField.h"
#import "iTetBlock.h"
#import "iTetGameRules.h"
#import "iTetKeyActions.h"
#import "NSMutableDictionary+KeyBindings.h"

#define LOCALPLAYER			[appController localPlayer]
#define NETCONTROLLER			[appController networkController]

NSTimeInterval blockFallDelayForLevel(NSInteger level);

@implementation iTetGameViewController

- (id)init
{
	actionHistory = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)awakeFromNib
{
	// Bind the game views to the app controller
	// Local field view (field and falling block)
	[localFieldView bind:@"field"
			toObject:appController
		   withKeyPath:@"localPlayer.field"
			 options:nil];
	[localFieldView bind:@"block"
			toObject:appController
		   withKeyPath:@"localPlayer.currentBlock"
			 options:nil];

	// Next block view
	[nextBlockView bind:@"block"
		     toObject:appController
		  withKeyPath:@"localPlayer.nextBlock"
			options:nil];
	
	// Specials queue view
	[specialsView bind:@"specials"
		    toObject:appController
		 withKeyPath:@"localPlayer.specialsQueue"
		     options:nil];
	
	// Remote field views
	[remoteFieldView1 bind:@"field"
			  toObject:appController
		     withKeyPath:@"remotePlayer1.field"
			   options:nil];
	[remoteFieldView2 bind:@"field"
			  toObject:appController
		     withKeyPath:@"remotePlayer2.field"
			   options:nil];
	[remoteFieldView3 bind:@"field"
			  toObject:appController
		     withKeyPath:@"remotePlayer3.field"
			   options:nil];
	[remoteFieldView4 bind:@"field"
			  toObject:appController
		     withKeyPath:@"remotePlayer4.field"
			   options:nil];
	[remoteFieldView5 bind:@"field"
			  toObject:appController
		     withKeyPath:@"remotePlayer5.field"
			   options:nil];
}

- (void)dealloc
{
	[currentGameRules release];
	[actionHistory release];
	
	// FIXME: ?
	[blockTimer invalidate];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)sendMessage:(id)sender
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Controlling Game State

- (void)newGameWithPlayers:(NSArray*)players
			   rules:(iTetGameRules*)rules
{
	// Clear the list of actions from the last game
	[self clearActions];
	
	// Retain the game rules
	[self setCurrentGameRules:rules];
	
	// Set up the players' fields
	for (iTetPlayer* player in players)
	{
		// Give the player a blank field
		[player setField:[iTetField field]];
		
		// Set the starting level
		[player setLevel:[rules startingLevel]];
	}
	
	// If there is a starting stack, give the local player a board with garbage
	if ([rules initialStackHeight] > 0)
	{
		// Create the board
		[LOCALPLAYER setField:[iTetField fieldWithStackHeight:[rules initialStackHeight]]];
		
		// Send the board to the server
		[self sendFieldstring];
	}
	
	// Create the first block to add to the field
	[LOCALPLAYER setNextBlock:[iTetBlock randomBlockUsingBlockFrequencies:[[self currentGameRules] blockFrequencies]]];
	
	// Move the block to the field
	[self moveNextBlockToField];
	
	// Create a new specials queue
	[LOCALPLAYER setSpecialsQueue:[NSMutableArray arrayWithCapacity:[[self currentGameRules] specialCapacity]]];
	
	// FIXME: anything else?
}

- (void)endGame
{
	// FIXME: WRITEME: additional actions to stop game?
	
	// Invalidate the block timer
	[blockTimer invalidate];
	
	// Clear the falling block
	[LOCALPLAYER setCurrentBlock:nil];
	
	// Remove the current game rules
	[self setCurrentGameRules:nil];
}

#pragma mark -
#pragma mark Gameplay Events

- (void)moveCurrentPieceDown
{
	// Attempt to move the block down
	if ([[LOCALPLAYER currentBlock] moveDownOnField:[LOCALPLAYER field]])
	{
		// If the block solidifies, add it to the field
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
	// Invalidate the old block timer (may be nil)
	[blockTimer invalidate];
	
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
	// Attempt to clear lines on the board
	BOOL linesCleared = NO;
	NSMutableArray* specials = [NSMutableArray array];
	NSUInteger numLines = [[LOCALPLAYER field] clearLinesAndRetrieveSpecials:specials];
	while (numLines > 0)
	{
		// Make a note that some lines were cleared
		linesCleared = YES;
		
		// Add the lines to the player's counts
		[LOCALPLAYER addLines:numLines];
		
		// Add any specials retrieved to the local player's queue
		for (NSNumber* special in specials)
		{
			// Check if there is space in the queue
			if ([[LOCALPLAYER specialsQueue] count] >= [[self currentGameRules] specialCapacity])
				break;
			
			// Add to player's queue
			[LOCALPLAYER addSpecialToQueue:special];
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
	// Set the block's position to the top of the field
	[[LOCALPLAYER nextBlock] setRowPos:
	 (ITET_FIELD_HEIGHT - ITET_BLOCK_HEIGHT) + [[LOCALPLAYER nextBlock] initialRowOffset]];
	
	// Center the block
	[[LOCALPLAYER nextBlock] setColPos:
	 ((ITET_FIELD_WIDTH - ITET_BLOCK_WIDTH)/2) + [[LOCALPLAYER nextBlock] initialColumnOffset]];
	
	// Transfer the next block to the field
	[LOCALPLAYER setCurrentBlock:[LOCALPLAYER nextBlock]];
	
	// FIXME: test if there is anything in the way of the block
	
	// Generate a new next block
	[LOCALPLAYER setNextBlock:[iTetBlock randomBlockUsingBlockFrequencies:[[self currentGameRules] blockFrequencies]]];
	
	// Set the fall timer
	blockTimer = [self fallTimer];
}

- (void)useSpecial:(iTetSpecialType)special
	    onTarget:(iTetPlayer*)target
	  fromSender:(iTetPlayer*)sender
		   
{
	// Get the affected player numbers
	NSInteger localNum, targetNum, senderNum;
	localNum = [LOCALPLAYER playerNumber];
	targetNum = [target playerNumber];
	senderNum = [sender playerNumber];
	
	// Check if this action affects the local player
	if ((targetNum != localNum) && (senderNum != localNum))
		return;
	
	// Determine the action to take
	switch (special)
	{
		case addLine:
			// If the local player is the target, add a line to the field
			if (targetNum == localNum)
			{
				[[LOCALPLAYER field] addLines:1];
				// FIXME: test for game over
			}
			break;
			
		case clearLine:
			// If the // If the local player is the target, remove the bottom line from the field
			if (targetNum == localNum)
				[[LOCALPLAYER field] clearBottomLine];
			break;
			
		case nukeField:
			// If the local player is the target, clear the field
			if (targetNum == localNum)
				[LOCALPLAYER setField:[iTetField field]];
			break;
			
		case randomClear:
			// If the local player is the target, clear random cells from the field
			if (targetNum == localNum)
				[[LOCALPLAYER field] clearRandomCells];
			break;
			
		case switchField:
			// If the local player is the target, get the sender's field
			if (targetNum == localNum)
				[LOCALPLAYER setField:[sender field]];
			// If the local player is the sender, get the target's field
			else if (senderNum == localNum)
				[LOCALPLAYER setField:[target field]];
			break;
			
		case clearSpecials:
			// If the local player is the target, clear all specials from the field
			if (targetNum == localNum)
				[[LOCALPLAYER field] removeAllSpecials];
			break;
			
		case gravity:
			// If the local player is the target, apply gravity to the field
			if (targetNum == localNum)
				[[LOCALPLAYER field] pullCellsDown];
			
			// Lines may be completed after a gravity special, but they don't count toward the player's lines cleared, and specials aren't collected
			[[LOCALPLAYER field] clearLines];
			
			break;
			
		case quakeField:
			// If the local player is the target, quake the field
			if (targetNum == localNum)
				[[LOCALPLAYER field] randomShiftRows];
			
			break;
			
		case blockBomb:
			// If the local player is the target, use block bomb
			if (targetNum == localNum);
				// FIXME: WRITEME: clear specials
			
			break;
			
		default:
			NSLog(@"WARNING: gameViewController -activateSpecial: called with invalid special type: %d", special);
	}
	
	// Send field changes to the server
	[self sendFieldstring];
}

#pragma mark iTetLocalBoardView Event Delegate Methods

- (void)keyPressed:(iTetKeyNamePair*)key
  onLocalFieldView:(iTetLocalFieldView*)fieldView
{
	// If there is no game in progress, or the game is paused, ignore
	if (![self gameInProgress] || [self gamePaused])
		return;
	
	// Determine whether the pressed key is bound to a game action
	NSMutableDictionary* keyConfig = [[iTetPreferencesController preferencesController] currentKeyConfiguration];
	iTetGameAction action = [keyConfig actionForKey:key];
	
	// Perform the relevant action
	iTetPlayer* targetPlayer;
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
			[self moveCurrentPieceDown];
			
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
			[LOCALPLAYER dequeueNextSpecial];
			break;
			
		case selfSpecial:
			// If the local player has specials, use one
			if ([[LOCALPLAYER specialsQueue] count] > 0)
			{
				[self sendSpecial:[LOCALPLAYER dequeueNextSpecial]
					   toPlayer:LOCALPLAYER];
			}
			break;
			
		case specialPlayer1:
			// If there is a player in the target slot, and the local player has specials, use one
			targetPlayer = [appController playerNumber:1];
			if ((targetPlayer != nil) && ([[LOCALPLAYER specialsQueue] count] > 0))
			{
				[self sendSpecial:[LOCALPLAYER dequeueNextSpecial]
					   toPlayer:targetPlayer];
			}
			break;
			
		case specialPlayer2:
			// If there is a player in the target slot, and the local player has specials, use one
			targetPlayer = [appController playerNumber:2];
			if ((targetPlayer != nil) && ([[LOCALPLAYER specialsQueue] count] > 0))
			{
				[self sendSpecial:[LOCALPLAYER dequeueNextSpecial]
					   toPlayer:targetPlayer];
			}
			break;
			
		case specialPlayer3:
			// If there is a player in the target slot, and the local player has specials, use one
			targetPlayer = [appController playerNumber:3];
			if ((targetPlayer != nil) && ([[LOCALPLAYER specialsQueue] count] > 0))
			{
				[self sendSpecial:[LOCALPLAYER dequeueNextSpecial]
					   toPlayer:targetPlayer];
			}
			break;
			
		case specialPlayer4:
			// If there is a player in the target slot, and the local player has specials, use one
			targetPlayer = [appController playerNumber:4];
			if ((targetPlayer != nil) && ([[LOCALPLAYER specialsQueue] count] > 0))
			{
				[self sendSpecial:[LOCALPLAYER dequeueNextSpecial]
					   toPlayer:targetPlayer];
			}
			break;
			
		case specialPlayer5:
			// If there is a player in the target slot, and the local player has specials, use one
			targetPlayer = [appController playerNumber:5];
			if ((targetPlayer != nil) && ([[LOCALPLAYER specialsQueue] count] > 0))
			{
				[self sendSpecial:[LOCALPLAYER dequeueNextSpecial]
					   toPlayer:targetPlayer];
			}
			break;
			
		case specialPlayer6:
			// If there is a player in the target slot, and the local player has specials, use one
			targetPlayer = [appController playerNumber:6];
			if ((targetPlayer != nil) && ([[LOCALPLAYER specialsQueue] count] > 0))
			{
				[self sendSpecial:[LOCALPLAYER dequeueNextSpecial]
					   toPlayer:targetPlayer];
			}
			break;
			
		case gameChat:
			// FIXME: WRITEME: 'game chat' key
			break;
	}
	
	// Not a recognized key; fall through
}

#pragma mark -
#pragma mark Client-to-Server Events

NSString* const iTetFieldstringMessageFormat = @"f %d %@";

- (void)sendFieldstring
{	
	// Send the string for the local player's field to the server
	[NETCONTROLLER sendMessage:[NSString stringWithFormat:iTetFieldstringMessageFormat, [LOCALPLAYER playerNumber], [[LOCALPLAYER field] fieldstring]]];
}

- (void)sendPartialFieldstring
{
	// Send the last partial update on the local player's field to the server
	[NETCONTROLLER sendMessage:[NSString stringWithFormat:iTetFieldstringMessageFormat, [LOCALPLAYER playerNumber], [[LOCALPLAYER field] lastPartialUpdate]]];
}

NSString* const iTetLevelMessageFormat = @"lvl %d %d";

- (void)sendCurrentLevel
{
	// Send the local player's level to the server
	[NETCONTROLLER sendMessage:[NSString stringWithFormat:iTetLevelMessageFormat, [LOCALPLAYER playerNumber], [LOCALPLAYER level]]];
}

NSString* const iTetSendSpecialMessageFormat = @"sb %d %c %d";

- (void)sendSpecial:(iTetSpecialType)special
	     toPlayer:(iTetPlayer*)player
{	
	// Send a message to the server
	[NETCONTROLLER sendMessage:[NSString stringWithFormat:iTetSendSpecialMessageFormat, [player playerNumber], (char)special, [LOCALPLAYER playerNumber]]];
	
	// Record and perform the action
	[self specialUsed:special
		   byPlayer:LOCALPLAYER
		   onPlayer:player];
}

#pragma mark -
#pragma mark Server-to-Client Events

NSString* const iTetSpecialEventDescriptionFormat =	@"%@ used on %@ by %@";
NSString* const iTetNilSenderNamePlaceholder =		@"Server";
NSString* const iTetNilTargetNamePlaceholder =		@"All";

- (void)specialUsed:(iTetSpecialType)special
	     byPlayer:(iTetPlayer*)sender
	     onPlayer:(iTetPlayer*)target
{
	// Perform the action, if applicable to the local player
	[self useSpecial:special
		  onTarget:target
		fromSender:sender];
	
	// Add a description of the event to the list of actions
	// FIXME: needs colors/formatting
	// Determine the name of the sender ("Server", if the sender is not a specific player)
	NSString* senderName;
	if (sender == nil)
		senderName = iTetNilSenderNamePlaceholder;
	else
		senderName = [sender nickname];
	    
	// Determine the name of the target ("All", if the target is not a specific player)
	NSString* targetName;
	if (target == nil)
		targetName = iTetNilTargetNamePlaceholder;
	else
		targetName = [target nickname];
	
	// Create the description string
	NSString* desc;
	desc = [NSString stringWithFormat:iTetSpecialEventDescriptionFormat, iTetNameForSpecialType(special), targetName, senderName];
	
	// Record the event
	[self recordAction:desc];
}

NSString* const iTetLineAddedEventDescriptionFormat = @"1 Line Added to All by %@";
NSString* const iTetLinesAddedEventDescriptionFormat = @"%d Lines Added to All by %@";

- (void)linesAdded:(NSInteger)numLines
	    byPlayer:(iTetPlayer*)sender
{
	// If the local player is not the sender, add the lines
	if ((sender == nil) || ([sender playerNumber] != [LOCALPLAYER playerNumber]))
	{
		[[LOCALPLAYER field] addLines:numLines];
		// FIXME: check for game over
	}
	
	// Create a description
	// FIXME: needs colors/formatting
	// Determine the name of the sender
	NSString* senderName;
	if (sender == nil)
		senderName = iTetNilSenderNamePlaceholder;
	else
		senderName = [sender nickname];
	
	// Choose a discription based on how many lines were added
	NSString* desc;
	if (numLines > 1)
		desc = [NSString stringWithFormat:iTetLinesAddedEventDescriptionFormat, numLines, senderName];
	else
		desc = [NSString stringWithFormat:iTetLineAddedEventDescriptionFormat, senderName];
	
	// Record the event
	[self recordAction:desc];
}

- (void)recordAction:(NSString*)description
{
	// Add the action to the list
	[actionHistory addObject:description];
	
	// Reload the action list table view
	[actionListView noteNumberOfRowsChanged];
	[actionListView scrollRowToVisible:([actionHistory count] - 1)];
}

- (void)clearActions
{
	[actionHistory removeAllObjects];
	[actionListView reloadData];
}

#pragma mark -
#pragma mark NSTableView Data Source Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
	return [actionHistory count];
}

- (id)tableView:(NSTableView*)tableView
objectValueForTableColumn:(NSTableColumn*)column
		row:(NSInteger)row
{
	return [actionHistory objectAtIndex:row];
}

#pragma mark -
#pragma mark Accessors

#define TETRINET_NEXT_BLOCK_DELAY	1.0

- (NSTimer*)nextBlockTimer
{
	// Create an invocation
	NSInvocation* i = [NSInvocation invocationWithMethodSignature:
				 [self methodSignatureForSelector:@selector(moveNextBlockToField)]];
	[i setTarget:self];
	[i setSelector:@selector(moveNextBlockToField)];
	
	// Start the timer to spawn the next block
	return [NSTimer scheduledTimerWithTimeInterval:TETRINET_NEXT_BLOCK_DELAY
							invocation:i
							   repeats:NO];
}

- (NSTimer*)fallTimer
{
	// Create an invocation
	NSInvocation* i = [NSInvocation invocationWithMethodSignature:
				 [self methodSignatureForSelector:@selector(moveCurrentPieceDown)]];
	[i setTarget:self];
	[i setSelector:@selector(moveCurrentPieceDown)];
	
	// Start the timer to move the block down
	return [NSTimer scheduledTimerWithTimeInterval:blockFallDelayForLevel([LOCALPLAYER level])
							invocation:i
							   repeats:YES];
}

#define ITET_MAX_DELAY_TIME			(1.005)
#define ITET_DELAY_REDUCTION_PER_LEVEL	(0.01)
#define ITET_MIN_DELAY_TIME			(0.005)

NSTimeInterval blockFallDelayForLevel(NSInteger level)
{
	NSTimeInterval time = ITET_MAX_DELAY_TIME - (level * ITET_DELAY_REDUCTION_PER_LEVEL);
	
	if (time < ITET_MIN_DELAY_TIME)
		return ITET_MIN_DELAY_TIME;
	
	return time;
}

@synthesize currentGameRules;

- (BOOL)gameInProgress
{
	return ([self currentGameRules] != nil);
}

- (void)setGamePaused:(BOOL)paused
{
	// FIXME: pause game in progress
	
	gamePaused = paused;
}
@synthesize gamePaused;

@end
