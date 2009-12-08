//
//  iTetGame.m
//  iTetrinet
//
//  Created by Alex Heinz on 12/3/09.
//

#import "iTetGame.h"
#import "iTetLocalPlayer.h"
#import "iTetGameRules.h"
#import "iTetBlock.h"
#import "Queue.h"

@implementation iTetGame

- (id)initWithPlayers:(NSArray*)participants
		    rules:(iTetGameRules*)gameRules;
{
	players = [participants retain];
	rules = [gameRules retain];
	
	for (iTetPlayer* player in players)
	{
		// If this is the local player, do some extra stuff
		if ([player isKindOfClass:[iTetLocalPlayer class]])
		{
			// Hold a reference
			localPlayer = (iTetLocalPlayer*)player;
			
			// Create a board with initial random garbage
			[player setBoard:[iTetBoard boardWithStackHeight:[rules initialStackHeight]]];
			
			// Create a clean specials queue
			[localPlayer setQueueSize:[rules specialCapacity]];
			[localPlayer setSpecialsQueue:[Queue queue]];
		}
		// Otherwise, just give the player a blank board
		else
		{
			[player setBoard:[iTetBoard board]];
		}
		
		// Set the starting level
		[player setLevel:[rules startingLevel]];
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

#pragma mark -
#pragma mark Accessors

- (void)setIsPaused:(BOOL)isPaused
{
	paused = isPaused;
	
	// FIXME: WRITEME
}
@synthesize paused;

@end
