//
//  iTetNoConnectingMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetNoConnectingMessage.h"

@implementation iTetNoConnectingMessage

- (void)dealloc
{
	[reason release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializer

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = noConnectingMessage;
	
	// Convert the data to a string
	reason = [[NSString alloc] initWithData:messageData
								   encoding:NSASCIIStringEncoding];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize reason;

@end
