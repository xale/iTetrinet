//
//  iTetLevelUpdateMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//

#import "iTetLevelUpdateMessage.h"
#import "iTetPlayer.h"
#import "NSString+MessageData.h"

@implementation iTetLevelUpdateMessage

+ (id)messageWithUpdateForPlayer:(iTetPlayer*)player
{
	return [[[self alloc] initWithLevel:[player level]
						forPlayerNumber:[player playerNumber]] autorelease];
}

- (id)initWithLevel:(NSInteger)newLevel
	forPlayerNumber:(NSInteger)number
{
	messageType = levelUpdateMessage;
	
	level = newLevel;
	playerNumber = number;
	
	return self;
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = levelUpdateMessage;
	
	// Convert the message data to an array of space-delimited strings
	NSArray* tokens = [[NSString stringWithMessageData:messageData] componentsSeparatedByString:@" "];
	
	// Parse the first token as the player number
	playerNumber = [[tokens objectAtIndex:0] integerValue];
	
	// Parse the second token as the level number
	level = [[tokens objectAtIndex:1] integerValue];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetLevelUpdateMessageFormat =	@"lvl %d %d";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetLevelUpdateMessageFormat, [self playerNumber], [self level]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

@synthesize level;
@synthesize playerNumber;

@end
