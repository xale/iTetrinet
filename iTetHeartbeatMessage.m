//
//  iTetHeartbeatMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetHeartbeatMessage.h"

@implementation iTetHeartbeatMessage

+ (id)message
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	messageType = heartbeatMessage;
	
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
	messageType = heartbeatMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

- (NSData*)rawMessageData
{
	// The heartbeat message is just a terminator, which the network controller will add
	return [NSData data];
}

@end
