//
//  iTetPlayerListEntryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/13/10.
//

#import "iTetPlayerListEntryMessage.h"
#import "NSString+MessageData.h"

@implementation iTetPlayerListEntryMessage

- (void)dealloc
{
	[nickname release];
	[teamName release];
	[version release];
	[channelName release];
	
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
	messageType = playerListEntryMessage;
	
	// Convert the data to a string, and split on quotation marks
	NSArray* quotedTokens = [[NSString stringWithMessageData:messageData] componentsSeparatedByString:@"\""];
	
	// Check that the message contains the correct number of quoted tokens
	if ([quotedTokens count] != 9)
		goto abort;
	
	// Treat the first quoted token as the player's nickname
	nickname = [[quotedTokens objectAtIndex:1] retain];
	
	// Treat the second quoted token as the player's team's name
	teamName = [[quotedTokens objectAtIndex:3] retain];
	
	// Treat the third quoted token as the version number of the protocol the client uses
	version = [[quotedTokens objectAtIndex:5] retain];
	
	// Treat the last quoted token as the name of the player's channel
	channelName = [[quotedTokens objectAtIndex:7] retain];
	
	// The space between the version number and the channel name contains additional information; split on spaces
	NSArray* remainingTokens = [[quotedTokens objectAtIndex:6] componentsSeparatedByString:@" "];
	
	// Check for the right number of tokens
	if ([remainingTokens count] != 5)
		goto abort;
	
	// Parse the tokens as integers
	playerNumber = [[remainingTokens objectAtIndex:1] integerValue];
	state = [[remainingTokens objectAtIndex:2] integerValue];
	authLevel = [[remainingTokens objectAtIndex:3] integerValue];
	
	return self;
	
abort:
	[self release];
	return nil;
}

#pragma mark -
#pragma mark Accessors

@synthesize nickname;
@synthesize teamName;
@synthesize version;
@synthesize playerNumber;
@synthesize state;
@synthesize authLevel;
@synthesize channelName;

@end
