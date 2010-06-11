//
//  iTetPlayerListQueryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/13/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerListQueryMessage.h"
#import "NSString+MessageData.h"

@implementation iTetPlayerListQueryMessage

+ (id)message
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	messageType = playerListQueryMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlayerListQueryMessageFormat =	@"listuser";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithString:iTetPlayerListQueryMessageFormat];
	
	return [rawMessage messageData];
}

@end
