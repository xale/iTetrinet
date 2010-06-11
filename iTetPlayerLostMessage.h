//
//  iTetPlayerLostMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetPlayerLostMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSInteger playerNumber;
}

+ (id)messageForPlayer:(iTetPlayer*)player;
- (id)initWithPlayerNumber:(NSInteger)playerNum;

@property (readonly) NSInteger playerNumber;

@end
