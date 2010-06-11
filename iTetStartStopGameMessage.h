//
//  iTetStartStopGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetStartStopGameMessage : iTetMessage <iTetOutgoingMessage>
{
	BOOL startGame;
	NSInteger senderNumber;
}

+ (id)startMessageFromSender:(iTetPlayer*)sender;
+ (id)stopMessageFromSender:(iTetPlayer*)sender;
- (id)initWithSenderNumber:(NSInteger)playerNumber
				 startGame:(BOOL)start;

@property (readonly) BOOL startGame;
@property (readonly) NSInteger senderNumber;

@end
