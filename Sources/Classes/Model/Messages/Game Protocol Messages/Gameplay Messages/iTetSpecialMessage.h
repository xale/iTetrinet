//
//  iTetSpecialMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetSpecialMessageTag;

@interface iTetSpecialMessage : iTetMessage
{
	NSInteger senderPlayerNumber;	/*!< The player-slot-number of the player sending the special, or 0, if sent by the server. */
	NSInteger targetPlayerNumber;	/*!< The player-slot-number of the player targetted by the special, or 0, if sent to all players. */
	NSString* specialDesignation;	/*!< The designation of the special being used. */
}

+ (id)messageWithSender:(NSInteger)senderNumber
				 target:(NSInteger)targetNumber
	 specialDesignation:(NSString*)special;
- (id)initWithSender:(NSInteger)senderNumber
			  target:(NSInteger)targetNumber
  specialDesignation:(NSString*)special;

@property (readonly) NSInteger senderPlayerNumber;
@property (readonly) NSInteger targetPlayerNumber;
@property (readonly) NSString* specialDesignation;

@end
