//
//  iTetLevelUpdateMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//

#import <Cocoa/Cocoa.h>
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
