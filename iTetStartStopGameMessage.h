//
//  iTetStartStopGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//

#import "iTetMessage.h"

@interface iTetStartStopGameMessage : iTetMessage <iTetOutgoingMessage>
{
	BOOL startGame;
	NSInteger senderNumber;
}

+ (id)startMessageWithSenderNumber:(NSInteger)playerNumber;
+ (id)stopMessageWithSenderNumber:(NSInteger)playerNumber;
- (id)initWithSenderNumber:(NSInteger)playerNumber
				 startGame:(BOOL)start;

@property (readonly) BOOL startGame;
@property (readonly) NSInteger senderNumber;

@end
