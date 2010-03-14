//
//  iTetPlayerWonMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/10/10.
//

#import "iTetPlayerWonMessage.h"
#import "NSString+ASCIIData.h"

@implementation iTetPlayerWonMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = playerWonMessage;
	
	// Convert the message to a string, and parse as the player number
	playerNumber = [[NSString stringWithASCIIData:messageData] integerValue];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
