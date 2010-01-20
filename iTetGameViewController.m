//
//  iTetGameViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import "iTetGameViewController.h"
#import "iTetAppController.h"
#import "iTetLocalPlayer.h"
#import "iTetLocalFieldView.h"
#import "iTetNextBlockView.h"
#import "iTetSpecialsView.h"
#import "iTetField.h"
#import "iTetGameRules.h"
#import "Queue.h"

@implementation iTetGameViewController

- (id)init
{
	actionHistory = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
	[currentGameRules release];
	[actionHistory release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)sendMessage:(id)sender
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Player-Field Assignment

- (void)addPlayer:(iTetPlayer*)player
{	
	// FIXME: WRITEME
	
	// No available controllers (shouldn't happen)
	//NSLog(@"WARNING: gameController addPlayer: called with no available controllers");
}

- (void)removePlayer:(iTetPlayer*)player
{
	// FIXME: WRITEME
	
	// Player not assigned to a controller (shouldn't happen)
	//NSLog(@"WARNING: gameController removePlayer: called on un-assigned player");
}

#pragma mark -
#pragma mark Controlling Game State

- (void)newGameWithPlayers:(NSArray*)players
			   rules:(iTetGameRules*)rules
{
	// Clear the list of actions from the last game
	[self clearActions];
	
	// Retain the game rules
	currentGameRules = [rules retain];
	
	// Set up the players' fields
	for (iTetPlayer* player in players)
	{
		// If this is the local player, do some extra stuff
		if ([player isKindOfClass:[iTetLocalPlayer class]])
		{	
			// Create a field with initial random garbage
			[player setField:[iTetField fieldWithStackHeight:[rules initialStackHeight]]];
			
			// Send the newly-created field to the server
			[self sendFieldstring];
		}
		// Otherwise, just give the player a blank field
		else
		{
			[player setField:[iTetField field]];
		}
		
		// Set the starting level
		[player setLevel:[rules startingLevel]];
	}
	
	// Create a clean specials queue for the local player
	[[appController localPlayer] setQueueSize:[rules specialCapacity]];
	[[appController localPlayer] setSpecialsQueue:[Queue queue]];
	
	// Set up the timer to spawn the first falling block
	// FIXME: WRITEME: block timer
	
	// FIXME: anything else to do here?
}

- (void)endGame
{
	// FIXME: WRITEME: additional actions to stop game?
	
	// Release and nil the game rules pointer
	[currentGameRules release];
	currentGameRules = nil;
}

#pragma mark -
#pragma mark Client-to-Server Events

NSString* const iTetFieldstringMessageFormat = @"f %d %@";

- (void)sendFieldstring
{
	iTetLocalPlayer* player = [appController localPlayer];
	
	// Send the string for the local player's field to the server
	[[appController networkController] sendMessage:
	 [NSString stringWithFormat:
	  iTetFieldstringMessageFormat,
	  [player playerNumber],
	  [[player field] fieldstring]]];
	 
}

- (void)sendPartialFieldstring
{
	iTetLocalPlayer* player = [appController localPlayer];
	
	// Send the last partial update on the local player's field to the server
	[[appController networkController] sendMessage:
	 [NSString stringWithFormat:
	  iTetFieldstringMessageFormat,
	  [player playerNumber],
	  [[player field] fieldstring]]];
}

#pragma mark -
#pragma mark Server-to-Client Events

NSString* const iTetSpecialEventDescriptionFormat = @"@% used on %@ by %@";

- (void)specialUsed:(iTetSpecialType)special
	     byPlayer:(iTetPlayer*)sender
	     onPlayer:(iTetPlayer*)target
{
	// Perform the action
	// FIXME: WRITEME
	
	// Add a description of the event to the list of actions
	// Determine the name of the target ("All", if the target is not a specific player)
	NSString* targetName;
	if (target == nil)
		targetName = @"All";
	else
		targetName = [target nickname];
	
	// Create the description string
	// FIXME: colors/formatting
	NSString* desc = [NSString stringWithFormat:iTetSpecialEventDescriptionFormat,
				iTetNameForSpecialType(special),
				targetName, [sender nickname]];
	
	// Record the event
	[self recordAction:desc];
}

NSString* const iTetLineAddedEventDescriptionFormat = @"1 Line Added to All by %@";
NSString* const iTetLinesAddedEventDescriptionFormat = @"%d Lines Added to All by %@";

- (void)linesAdded:(int)numLines
	    byPlayer:(iTetPlayer*)sender
{
	// Add the lines
	// FIXME: WRITEME
	
	// Create a description
	// FIXME: colors/formatting
	NSString* desc;
	if (numLines > 1)
	{
		desc = [NSString stringWithFormat:iTetLinesAddedEventDescriptionFormat,
			  numLines, [sender nickname]];
	}
	else
	{
		desc = [NSString stringWithFormat:iTetLineAddedEventDescriptionFormat,
			  [sender nickname]];
	}
	
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
#pragma mark iTetLocalBoardView Event Delegate Methods

- (void)keyPressed:(iTetKeyNamePair*)key
  onLocalFieldView:(iTetLocalFieldView*)fieldView
{
	// If there is no game in progress, or the game is paused, ignore
	if (![self gameInProgress] || [self gamePaused])
		return;
	
	// FIXME: WRITEME
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

- (BOOL)gameInProgress
{
	return (currentGameRules != nil);
}

- (void)setGamePaused:(BOOL)paused
{
	// FIXME: pause game in progress
	
	gamePaused = paused;
}
@synthesize gamePaused;

@end
