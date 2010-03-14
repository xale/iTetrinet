//
//  iTetNewGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//

#import "iTetNewGameMessage.h"
#import "NSString+ASCIIData.h"

@implementation iTetNewGameMessage

- (void)dealloc
{
	[rulesList release];
	
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
	messageType = newGameMessage;
	
	// Convert the message data to a string, and split into space-delimited tokens
	rulesList = [[[NSString stringWithASCIIData:messageData] componentsSeparatedByString:@" "] retain];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize rulesList;

@end
