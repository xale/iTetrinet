//
//  iTetPlayerNumberMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@interface iTetPlayerNumberMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The slot number being assigned to the local player. */
}

+ (id)messageWithPlayerNumber:(NSInteger)number;
- (id)initWithPlayerNumber:(NSInteger)number;

/*!
 @warning Abstract method; subclasses must override.
 Returns the message tag used by this player number message, which varies from one protocol to another.
 */
- (NSString*)messageTag;

@property (readonly) NSInteger playerNumber;

@end
