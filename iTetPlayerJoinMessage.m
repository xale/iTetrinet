//
//  iTetPlayerJoinMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetPlayerJoinMessage.h"
#import "NSString+MessageData.h"

@implementation iTetPlayerJoinMessage

- (void)dealloc
{
	[nickname release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = playerJoinMessage;
	
	// Convert the message data to a string
	NSString* rawMessage = [NSString stringWithMessageData:messageData];
	
	// Split into space-delimited tokens
	NSArray* messageTokens = [rawMessage componentsSeparatedByString:@" "];
	
	// Parse the first token as the player number
	playerNumber = [[messageTokens objectAtIndex:0] integerValue];
	
	// Treat the second token as the player nickname
	nickname = [[messageTokens objectAtIndex:1] copy];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize nickname;

@end
