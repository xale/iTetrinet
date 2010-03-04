//
//  iTetStartStopGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetStartStopGameMessage : iTetMessage <iTetOutgoingMessage>
{
	BOOL startGame;
	NSInteger senderNumber;
}

+ (id)startGameMessageWithSenderNumber:(NSInteger)playerNumber;
+ (id)stopGameMessageWithSenderNumber:(NSInteger)playerNumber;
- (id)initWithSenderNumber:(NSInteger)playerNumber
				 startGame:(BOOL)start;

@property (readonly) BOOL startGame;
@property (readonly) NSInteger senderNumber;

@end
