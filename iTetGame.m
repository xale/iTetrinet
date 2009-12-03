//
//  iTetGame.m
//  iTetrinet
//
//  Created by Alex Heinz on 12/3/09.
//

#import "iTetGame.h"
#import "iTetLocalPlayer.h"
#import "iTetGameRules.h"

@implementation iTetGame

- (id)initWithPlayers:(NSArray*)participants
		    rules:(iTetGameRules*)gameRules
	  startingLevel:(int)startingLevel
   initialStackHeight:(int)stackHeight
{
	players = [participants retain];
	rules = [gameRules retain];
	
	for (iTetPlayer* player in players)
	{
		// If this is the local player, hold a reference, and create a board
		// with the starting stack height
		if ([player isKindOfClass:[iTetLocalPlayer class]])
		{
			localPlayer = (iTetLocalPlayer*)player;
			[player setBoard:[iTetBoard boardWithStackHeight:stackHeight]];
		}
		// Otherwise, give the player a blank board
		else
		{
			[player setBoard:[iTetBoard board]];
		}
		
		// Set the starting level
		[player setLevel:startingLevel];
	}
	
	// Set up the timer to spawn the first falling block
	// FIXME: WRITEME: block timer
	
	return self;
}

- (void)dealloc
{
	[players release];
	[rules release];
	
	[blockTimer release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Specials/Lines

- (void)specialUsed:(iTetSpecialType)special
	     byPlayer:(iTetPlayer*)sender
	     onPlayer:(iTetPlayer*)target
{
	// FIXME: WRITEME
}

- (void)linesAdded:(int)numLines
	    byPlayer:(iTetPlayer*)sender
{
	// FIXME: WRITEME
}

@end
