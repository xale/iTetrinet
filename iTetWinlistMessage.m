//
//  iTetWinlistMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetWinlistMessage.h"
#import "NSString+MessageData.h"

@implementation iTetWinlistMessage

- (void)dealloc
{
	[winlistTokens release];
	
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
	messageType = winlistMessage;
	
	// Convert the message data to a string
	NSString* rawMessage = [NSString stringWithMessageData:messageData];
	
	// Split into space-delimited tokens
	winlistTokens = [[rawMessage componentsSeparatedByString:@" "] retain];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize winlistTokens;

@end
