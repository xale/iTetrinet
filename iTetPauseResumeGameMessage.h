//
//  iTetPauseResumeGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetPauseResumeGameMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	BOOL pauseGame;
	NSInteger senderNumber;
}

+ (id)pauseMessageFromSender:(iTetPlayer*)sender;
+ (id)resumeMessageFromSender:(iTetPlayer*)sender;
- (id)initWithSenderNumber:(NSInteger)playerNumber
				 pauseGame:(BOOL)pause;

@property (readonly) BOOL pauseGame;
@property (readonly) NSInteger senderNumber;

@end
