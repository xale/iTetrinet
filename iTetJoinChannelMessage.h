//
//  iTetJoinChannelMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/11/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetJoinChannelMessage : iTetMessage <iTetOutgoingMessage>
{
	NSString* channelName;
	NSInteger playerNumber;
}

+ (id)messageWithChannelName:(NSString*)nameOfChannel
					  player:(iTetPlayer*)player;
- (id)initWithChannelName:(NSString*)nameOfChannel
				   player:(iTetPlayer*)player;

@property (readonly) NSString* channelName;
@property (readonly) NSInteger playerNumber;

@end
