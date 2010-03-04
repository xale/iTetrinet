//
//  iTetNoConnectingMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetNoConnectingMessage.h"
#import "NSString+ASCIIData.h"

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
	reason = [[NSString stringWithASCIIData:messageData] retain];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize reason;

@end
