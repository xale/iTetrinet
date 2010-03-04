//
//  iTetGameChatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetGameChatMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSString* messageContents;
}

+ (id)messageWithContents:(NSString*)contents
				   sender:(NSString*)senderNickname;
+ (id)messageWithContents:(NSString*)contents;
- (id)initWithContents:(NSString*)contents;

@property (readonly) NSString* messageContents;

@end
