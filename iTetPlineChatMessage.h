//
//  iTetPlineChatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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

- (NSData*)rawMessageDataWithInitialFormat:(NSString*)initialFormat;

@property (readonly) NSInteger senderNumber;
@property (readonly) NSAttributedString* messageContents;

@end
