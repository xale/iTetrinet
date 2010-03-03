//
//  iTetPlayerNumberMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetPlayerNumberMessage.h"

@implementation iTetPlayerNumberMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializer

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = playerNumberMessage;
	
	// Convert the message data to a string
	NSString* rawMessage = [[[NSString alloc] initWithData:messageData
												  encoding:NSASCIIStringEncoding] autorelease];
	
	// Read the player number as an integer
	playerNumber = [rawMessage integerValue];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
