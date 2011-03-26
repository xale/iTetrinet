//
//  iTetPlayerJoinMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetPlayerJoinMessageTag;

@interface iTetPlayerJoinMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The player-slot-number assigned to the joining player. */
	NSString* playerNickname;	/*!< The joining player's nickname. */
}

+ (id)messageWithPlayerNumber:(NSInteger)number
					 nickname:(NSString*)nickname;
- (id)initWithPlayerNumber:(NSInteger)number
				  nickname:(NSString*)nickname;

@property (readonly) NSInteger playerNumber;
@property (readonly) NSString* playerNickname;

@end
