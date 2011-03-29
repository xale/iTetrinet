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
				currentPlayers:(NSInteger)currentPlayerCount
					maxPlayers:(NSInteger)maxPlayers
					  priority:(NSInteger)priority
						 state:(iTetGameplayState)gameState
{
	return [[[self alloc] initWithName:name
						   description:desc
						currentPlayers:currentPlayerCount
							maxPlayers:maxPlayers
							  priority:priority
								 state:gameState] autorelease];
}

- (id)initWithName:(NSString*)name
	   description:(NSString*)desc
	currentPlayers:(NSInteger)currentPlayerCount
		maxPlayers:(NSInteger)maxPlayers
		  priority:(NSInteger)priority
			 state:(iTetGameplayState)gameState
{
	if (!(self = [super init]))
		return nil;
	
	channelName = [name copy];
	channelDescription = [desc copy];
	playerCount = currentPlayerCount;
	maxPlayerCount = maxPlayers;
	channelState = gameState;
	channelPriority = priority;
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
#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
	return [[[self class] allocWithZone:zone] initWithName:[self channelName]
											   description:[self channelDescription]
											currentPlayers:[self playerCount]
												maxPlayers:[self maxPlayerCount]
												  priority:[self channelPriority]
													 state:[self channelState]];
}

#pragma mark -
#pragma mark Accessors

@synthesize channelName;
@synthesize channelDescription;

@synthesize playerCount;
@synthesize maxPlayerCount;
- (NSString*)players
{
	return [NSString localizedStringWithFormat:@"%d / %d", [self playerCount], [self maxPlayerCount]];
}
- (NSNumber*)sortablePlayers
{
	return [NSNumber numberWithDouble:([self playerCount] + ([self maxPlayerCount] / 100.0))];
}

@synthesize channelPriority;

@synthesize channelState;
- (NSNumber*)sortableState
{
	switch ([self channelState])
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
