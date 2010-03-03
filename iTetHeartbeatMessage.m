//
//  iTetHeartbeatMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetHeartbeatMessage.h"

@implementation iTetHeartbeatMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializer

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = heartbeatMessage;
	
	// No data fields
	
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
