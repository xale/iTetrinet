//
//  iTetClientInfoRequestMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetClientInfoRequestMessage.h"

@implementation iTetClientInfoRequestMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = clientInfoRequestMessage;
	
	// No data fields
	
	return self;
}

@end
