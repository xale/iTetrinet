//
//  iTetPlineActionMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/10/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"
#import "iTetPlineActionMessage.h"

@implementation iTetPlineActionMessage

- (id)initWithContents:(NSAttributedString*)contentsOfMessage
	  fromPlayerNumber:(NSInteger)playerNumber
{
	if (![super initWithContents:contentsOfMessage fromPlayerNumber:playerNumber])
		return nil;
	
	messageType = plineActionMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	if (![super initWithMessageData:messageData])
		return nil;
	
	messageType = plineActionMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlineActionMessageFormat =	@"plineact %d ";

- (NSData*)rawMessageData
{
	// Create the message format
	NSString* initialFormat = [NSString stringWithFormat:iTetPlineActionMessageFormat, [self senderNumber]];
	
	// Convert to NSData, append the contents, and return
	return [self rawMessageDataWithInitialFormat:initialFormat];
}

@end
