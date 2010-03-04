//
//  iTetPlineMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetPlineMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSInteger senderNumber;
	NSAttributedString* messageContents;
	BOOL action;
}

+ (id)messageWithContents:(NSAttributedString*)contentsOfMessage
		 fromPlayerNumber:(NSInteger)playerNumber
			actionMessage:(BOOL)isAction;
- (id)initWithContents:(NSAttributedString*)contentsOfMessage
	  fromPlayerNumber:(NSInteger)playerNumber
		 actionMessage:(BOOL)isAction;

@property (readonly) NSInteger senderNumber;
@property (readonly) NSAttributedString* messageContents;
@property (readonly, getter=isAction) BOOL action;

@end
