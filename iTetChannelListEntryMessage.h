//
//  iTetChannelListEntryMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
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
