//
//  iTetLevelUpdateMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetLevelUpdateMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSInteger level;
	NSInteger playerNumber;
}

+ (id)messageWithUpdateForPlayer:(iTetPlayer*)player;
- (id)initWithLevel:(NSInteger)newLevel
	forPlayerNumber:(NSInteger)number;

@property (readonly) NSInteger level;
@property (readonly) NSInteger playerNumber;

@end
