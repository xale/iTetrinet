//
//  iTetGameChatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/27/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetGameChatMessageTag;

@interface iTetGameChatMessage : iTetMessage
{
	NSString* chatContents;	/*!< The contents of the chat message. */
}

+ (id)messageWithChatContents:(NSString*)contents;
- (id)initWithChatContents:(NSString*)contents;

@property (readonly) NSString* chatContents;

@end
