//
//  iTetGameChatMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//

#import "iTetGameChatMessage.h"
#import "NSString+ASCIIData.h"

@implementation iTetGameChatMessage

// If we are including a sender name, use the GTetrinet-style angle-bracket format:
NSString* const iTetGameChatMessageWithSenderFormat =	@"<%@> %@";

+ (id)messageWithContents:(NSString*)contents
				   sender:(NSString*)senderNickname
{
	NSString* fullContents = [NSString stringWithFormat:iTetGameChatMessageWithSenderFormat, senderNickname, contents];
	
	return [[[self alloc] initWithContents:fullContents] autorelease];
}

+ (id)messageWithContents:(NSString*)contents
{
	return [[[self alloc] initWithContents:contents] autorelease];
}

- (id)initWithContents:(NSString*)contents
{
	messageType = gameChatMessage;
	
	messageContents = [contents copy];
	
	return self;
}

- (void)dealloc
{
	[messageContents release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = gameChatMessage;
	
	// Convert the message data to a string
	messageContents = [[NSString stringWithASCIIData:messageData] retain];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetGameChatMessageFormat =	@"gmsg %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetGameChatMessageFormat, [self messageContents]];
	
	return [rawMessage dataUsingEncoding:NSASCIIStringEncoding
					allowLossyConversion:YES];
}

#pragma mark -
#pragma mark Accessors

@synthesize messageContents;

@end
