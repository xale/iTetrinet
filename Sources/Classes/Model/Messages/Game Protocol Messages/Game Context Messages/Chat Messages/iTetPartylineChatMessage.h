//
//  iTetPartylineChatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/27/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetPartylineChatMessageTag;

@interface iTetPartylineChatMessage : iTetMessage
{
	NSInteger senderPlayerNumber;	/*!< The player-slot-number of the player sending the message. */
	NSAttributedString* chatContents;	/*!< The contents of the chat message, after applying text colors and font traits parsed from the message data. */
}

+ (id)messageWithChatContents:(NSAttributedString*)contents
					   sender:(NSInteger)playerNumber;
- (id)initWithChatContents:(NSAttributedString*)contents
					sender:(NSInteger)playerNumber;

- (NSString*)messageTag;

@property (readonly) NSInteger senderPlayerNumber;
@property (readonly) NSAttributedString* chatContents;

@end
