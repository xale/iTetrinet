//
//  iTetPlayerLostMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerLostMessage.h"
#import "iTetPlayer.h"
#import "NSString+MessageData.h"

@implementation iTetPlayerLostMessage

+ (id)messageForPlayer:(iTetPlayer*)player
{
	return [[[self alloc] initWithPlayerNumber:[player playerNumber]] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)playerNum
{
	messageType = playerLostMessage;
	
	playerNumber = playerNum;
	
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
	messageType = playerLostMessage;
	
	// Convert the message to a string, and parse as the player number
	playerNumber = [[NSString stringWithMessageData:messageData] integerValue];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlayerLostMessageFormat =	@"playerlost %d";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetPlayerLostMessageFormat, [self playerNumber]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
