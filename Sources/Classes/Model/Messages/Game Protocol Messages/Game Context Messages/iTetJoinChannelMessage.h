//
//  iTetJoinChannelMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/29/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetJoinChannelCommandTag;

@interface iTetJoinChannelMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The player-slot-number of the player changing channels. */
	NSString* channelName;	/*!< The name of the channel the player is moving to, excluding the '#' mark, if any. */
}

+ (id)messageWithPlayerNumber:(NSInteger)number
				  channelName:(NSString*)channel;
- (id)initWithPlayerNumber:(NSInteger)number
			   channelName:(NSString*)channel;

@property (readonly) NSInteger playerNumber;
@property (readonly) NSString* channelName;

@end
