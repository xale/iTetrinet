//
//  iTetPauseResumeGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
//

#import "iTetMessage.h"

@interface iTetPauseResumeGameMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	BOOL pauseGame;
	NSInteger senderNumber;
}

+ (id)pauseMessageWithSenderNumber:(NSInteger)playerNumber;
+ (id)resumeMessageWithSenderNumber:(NSInteger)playerNumber;
- (id)initWithSenderNumber:(NSInteger)playerNumber
				 pauseGame:(BOOL)pause;

@property (readonly) BOOL pauseGame;
@property (readonly) NSInteger senderNumber;

@end
