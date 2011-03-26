//
//  iTetPlayerLeaveMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetPlayerLeaveMessageTag;

@interface iTetPlayerLeaveMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The number of the (now vacated) slot the leaving player occupied. */
}

+ (id)messageWithPlayerNumber:(NSInteger)number;
- (id)initWithPlayerNumber:(NSInteger)number;

@property (readonly) NSInteger playerNumber;

@end
