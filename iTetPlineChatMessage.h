//
//  iTetPlineChatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetPlineChatMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSInteger senderNumber;
	NSAttributedString* messageContents;
}

+ (id)messageWithContents:(NSAttributedString*)contentsOfMessage
			   fromPlayer:(iTetPlayer*)player;
- (id)initWithContents:(NSAttributedString*)contentsOfMessage
	  fromPlayerNumber:(NSInteger)playerNumber;

- (NSData*)rawMessageDataByAppendingContentsToString:(NSString*)initialFormat;

@property (readonly) NSInteger senderNumber;
@property (readonly) NSAttributedString* messageContents;

@end
