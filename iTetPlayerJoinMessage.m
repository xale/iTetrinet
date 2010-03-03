//
//  iTetPlayerJoinMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetPlayerJoinMessage.h"

@implementation iTetPlayerJoinMessage

- (void)dealloc
{
	[nickname release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializer

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = playerJoinMessage;
	
	// Convert the message data to a string
	NSString* rawMessage = [[[NSString alloc] initWithData:messageData
												  encoding:NSASCIIStringEncoding] autorelease];
	
	// Split into space-delimited tokens
	NSArray* messageTokens = [rawMessage componentsSeparatedByString:@" "];
	
	// Parse the first token as the player number
	playerNumber = [[messageTokens objectAtIndex:0] integerValue];
	
	// Treat the second token as the player nickname
	nickname = [[messageTokens objectAtIndex:1] retain];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize nickname;

@end
