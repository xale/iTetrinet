//
//  iTetClientInfoRequestMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetClientInfoRequestMessage.h"

@implementation iTetClientInfoRequestMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializer

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = clientInfoRequestMessage;
	
	// No data fields
	
	return self;
}

@end
