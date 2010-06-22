//
//  iTetChannelListEntryMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"
#import "iTetGameplayState.h"

@interface iTetChannelListEntryMessage : iTetMessage <iTetIncomingMessage>
{
	NSString* channelName;
	NSString* channelDescription;
	NSInteger playerCount;
	NSInteger maxPlayers;
	NSInteger priority;
	iTetGameplayState gameState;
}

@property (readonly) NSString* channelName;
@property (readonly) NSString* channelDescription;
@property (readonly) NSInteger playerCount;
@property (readonly) NSInteger maxPlayers;
@property (readonly) NSInteger priority;
@property (readonly) iTetGameplayState gameState;

@end
