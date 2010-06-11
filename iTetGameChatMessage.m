//
//  iTetGameChatMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGameChatMessage.h"
#import "iTetPlayer.h"
#import "NSString+MessageData.h"

@implementation iTetGameChatMessage

// If we are including a sender name, use the GTetrinet-style angle-bracket format:
NSString* const iTetGameChatMessageWithSenderFormat =	@"<%@> %@";

+ (id)messageWithContents:(NSString*)contents
				   sender:(iTetPlayer*)sender
{
	NSString* fullContents = [NSString stringWithFormat:iTetGameChatMessageWithSenderFormat, [sender nickname], contents];
	
	return [[[self alloc] initWithContents:fullContents] autorelease];
}

+ (id)messageWithContents:(NSString*)contents
{
	return [[[self alloc] initWithContents:contents] autorelease];
}

- (id)initWithContents:(NSString*)contents
{
	messageType = gameChatMessage;
	
	messageContents = [[contents componentsSeparatedByString:@" "] retain];
	
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
	
	// Convert the message data to an array of space-delimited strings
	messageContents = [[[NSString stringWithMessageData:messageData] componentsSeparatedByString:@" "] retain];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetGameChatMessageFormat =	@"gmsg %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetGameChatMessageFormat, [self messageContents]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

- (NSString*)messageContents
{
	return [messageContents componentsJoinedByString:@" "];
}

- (NSString*)firstWord
{
	if ([messageContents count] > 0)
		return [messageContents objectAtIndex:0];
	
	return [NSString string];
}

- (NSString*)contentsAfterFirstWord
{
	if ([messageContents count] > 1)
		return [[messageContents subarrayWithRange:NSMakeRange(1, [messageContents count] - 1)] componentsJoinedByString:@" "];
	
	return [NSString string];
}

@end
