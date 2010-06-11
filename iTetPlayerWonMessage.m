//
//  iTetPlayerWonMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/10/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerWonMessage.h"
#import "NSString+MessageData.h"

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
	playerNumber = [[NSString stringWithMessageData:messageData] integerValue];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
