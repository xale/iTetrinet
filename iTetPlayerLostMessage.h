//
//  iTetPlayerLostMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
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
