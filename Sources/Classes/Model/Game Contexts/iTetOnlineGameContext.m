//
//  iTetOnlineGameContext.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetOnlineGameContext.h"

@implementation iTetOnlineGameContext

#pragma mark -
#pragma mark Accessors

- (NSArray*)channelPlayers
{
	return channelPlayers;
}

- (NSAttributedString*)chatHistory
{
	return chatHistory;
}

- (NSArray*)serverChannels
{
	return [serverChannels allObjects];
}

- (NSArray*)serverPlayers
{
	return [serverPlayers allObjects];
}

#pragma mark Overrides

- (BOOL)isOfflineContext
{
	return NO;
}

@end
