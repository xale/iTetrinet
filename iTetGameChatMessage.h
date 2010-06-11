//
//  iTetGameChatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetGameChatMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSArray* messageContents;
}

+ (id)messageWithContents:(NSString*)contents
				   sender:(iTetPlayer*)sender;
+ (id)messageWithContents:(NSString*)contents;
- (id)initWithContents:(NSString*)contents;

@property (readonly) NSString* messageContents;
@property (readonly) NSString* firstWord;
@property (readonly) NSString* contentsAfterFirstWord;

@end
