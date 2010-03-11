//
//  iTetPlineActionMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/10/10.
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
	
	// Append the message contents, convert to NSData, and return
	return [super rawMessageDataByAppendingContentsToString:initialFormat];
}

@end
