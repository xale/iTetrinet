//
//  iTetNoConnectingMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNoConnectingMessage.h"
#import "NSString+MessageData.h"

@implementation iTetNoConnectingMessage

- (void)dealloc
{
	[reason release];
	
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
	messageType = noConnectingMessage;
	
	// Convert the data to a string
	reason = [[NSString stringWithMessageData:messageData] retain];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize reason;

@end
