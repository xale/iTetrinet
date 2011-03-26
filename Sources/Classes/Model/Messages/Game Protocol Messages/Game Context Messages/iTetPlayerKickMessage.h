//
//  iTetPlayerKickMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/22/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetPlayerKickMessageTag;

@interface iTetPlayerKickMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The player-slot-number of the player being kicked. */
}

+ (id)messageWithPlayerNumber:(NSInteger)number;
- (id)initWithPlayerNumber:(NSInteger)number;

@property (readonly) NSInteger playerNumber;

@end
