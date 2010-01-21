//
//  iTetGameViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import "iTetGameViewController.h"
#import "iTetAppController.h"
#import "iTetPlayer.h"
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

- (void)awakeFromNib
{
	// Bind the game views to the app controller
	[localFieldView bind:@"field"
			toObject:appController
		   withKeyPath:@"localPlayer.field"
			 options:nil];
	// FIXME: bind next block view
	// FIXME: bind specials view
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
	currentGameRules = [rules retain];
	
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
		[[appController localPlayer] setField:
		 [iTetField fieldWithStackHeight:[rules initialStackHeight]]];
		
		// Send the board to the server
		[self sendFieldstring];
	}
	
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
	// Send the string for the local player's field to the server
	iTetPlayer* player = [appController localPlayer];
	[[appController networkController] sendMessage:
	 [NSString stringWithFormat:
	  iTetFieldstringMessageFormat, [player playerNumber], [[player field] fieldstring]]];
}

- (void)sendPartialFieldstring
{
	// Send the last partial update on the local player's field to the server
	iTetPlayer* player = [appController localPlayer];
	[[appController networkController] sendMessage:
	 [NSString stringWithFormat:
	  iTetFieldstringMessageFormat, [player playerNumber], [[player field] lastPartialUpdate]]];
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
