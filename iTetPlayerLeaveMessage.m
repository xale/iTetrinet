//
//  iTetPlayerLeaveMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetPlayerLeaveMessage.h"
#import "NSString+MessageData.h"

@implementation iTetPlayerLeaveMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = playerLeaveMessage;
	
	// Convert the message data to a string
	NSString* rawMessage = [NSString stringWithMessageData:messageData];
	
	// Read the player number as an integer
	playerNumber = [rawMessage integerValue];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
