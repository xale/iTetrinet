//
//  iTetGameChatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetGameChatMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSString* messageContents;
}

+ (id)messageWithContents:(NSString*)contents
				   sender:(iTetPlayer*)sender;
+ (id)messageWithContents:(NSString*)contents;
- (id)initWithContents:(NSString*)contents;

@property (readonly) NSString* messageContents;

@end
