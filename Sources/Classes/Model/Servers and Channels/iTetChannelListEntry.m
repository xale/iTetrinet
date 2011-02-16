//
//  iTetChannelListEntry.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/23/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetChannelListEntry.h"

@implementation iTetChannelListEntry

+ (id)channelListEntryWithName:(NSString*)name
				   description:(NSString*)desc
				currentPlayers:(NSInteger)playerCount
					maxPlayers:(NSInteger)max
						 state:(iTetGameplayState)gameState
{
	return [[[self alloc] initWithName:name
						   description:desc
						currentPlayers:playerCount
							maxPlayers:max
								 state:gameState] autorelease];
}

- (id)initWithName:(NSString*)name
	   description:(NSString*)desc
	currentPlayers:(NSInteger)playerCount
		maxPlayers:(NSInteger)max
			 state:(iTetGameplayState)gameState
{
	channelName = [name copy];
	channelDescription = [desc copy];
	currentPlayers = playerCount;
	maxPlayers = max;
	channelState = gameState;
	localPlayerChannel = NO;
	
	return self;
}

- (void)dealloc
{
	[channelName release];
	[channelDescription release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize channelName;
@synthesize channelDescription;

- (NSString*)players
{
	return [NSString localizedStringWithFormat:@"%d / %d", currentPlayers, maxPlayers];
}

- (NSNumber*)sortablePlayers
{
	return [NSNumber numberWithDouble:(currentPlayers + (maxPlayers / 100.0))];
}

@synthesize channelState;

- (NSNumber*)sortableState
{
	switch (channelState)
	{
		case gamePlaying:
			return [NSNumber numberWithInt:2];
		case gamePaused:
			return [NSNumber numberWithInt:1];
		default:
			return [NSNumber numberWithInt:0];
	}
}

@synthesize localPlayerChannel;

@end
