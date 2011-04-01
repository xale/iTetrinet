//
//  iTetPlayerWonMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetPlayerWonMessageTag;

@interface iTetPlayerWonMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The player-slot-number of the winning player. */
}

+ (id)messageWithPlayerNumber:(NSInteger)number;
- (id)initWithPlayerNumber:(NSInteger)number;

@property (readonly) NSInteger playerNumber;

@end
