//
//  iTetNoConnectingMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetNoConnectingMessage.h"

@implementation iTetNoConnectingMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializer

- (id)initWithMessageData:(NSData*)data
{
	// Convert the data to a string
	reason = [[NSString alloc] initWithData:data
								   encoding:NSASCIIStringEncoding];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize reason;

@end
