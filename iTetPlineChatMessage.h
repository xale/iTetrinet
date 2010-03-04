//
//  iTetPlineChatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetPlineChatMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSInteger senderNumber;
	NSAttributedString* messageContents;
}

+ (id)plineChatMessageWithContents:(NSAttributedString*)contentsOfMessage
				  fromPlayerNumber:(NSInteger)playerNumber;
- (id)initWithContents:(NSAttributedString*)contentsOfMessage
	  fromPlayerNumber:(NSInteger)playerNumber;

@property (readonly) NSInteger senderNumber;
@property (readonly) NSAttributedString* messageContents;

@end
