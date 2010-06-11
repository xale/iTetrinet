//
//  iTetPlayerTeamMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerTeamMessage.h"
#import "iTetPlayer.h"
#import "NSString+MessageData.h"

@implementation iTetPlayerTeamMessage

+ (id)messageForPlayer:(iTetPlayer*)player
{
	return [[[self alloc] initWithPlayerNumber:[player playerNumber]
									  teamName:[player teamName]] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)number
				  teamName:(NSString*)nameOfTeam
{
	messageType = playerTeamMessage;
	
	playerNumber = number;
	teamName = [nameOfTeam copy];
	
	return self;
}

- (void)dealloc
{
	[teamName release];
	
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
	messageType = playerTeamMessage;
	
	// Convert the message data to a string
	NSString* rawMessage = [NSString stringWithMessageData:messageData];
	
	// Split into space-delimited tokens
	NSArray* messageTokens = [rawMessage componentsSeparatedByString:@" "];
	
	// Parse the first token as the player number
	playerNumber = [[messageTokens objectAtIndex:0] integerValue];
	
	// Treat the second token (if present) as the player's team name
	if ([messageTokens count] >= 2)
		teamName = [[[messageTokens subarrayWithRange:NSMakeRange(1, ([messageTokens count] - 1))] componentsJoinedByString:@" "] retain];
	else
		teamName = [[NSString alloc] init];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlayerTeamMessageFormat =	@"team %d %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetPlayerTeamMessageFormat, [self playerNumber], [self teamName]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize teamName;

@end
