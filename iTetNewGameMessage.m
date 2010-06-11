//
//  iTetNewGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNewGameMessage.h"
#import "NSString+MessageData.h"

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
	rulesList = [[[NSString stringWithMessageData:messageData] componentsSeparatedByString:@" "] retain];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize rulesList;

@end
