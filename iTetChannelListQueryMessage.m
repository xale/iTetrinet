//
//  iTetChannelListQueryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetChannelListQueryMessage.h"
#import "NSString+MessageData.h"

@implementation iTetChannelListQueryMessage

+ (id)message
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	messageType = channelListQueryMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetChannelListQueryMessageFormat =	@"listchan";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithString:iTetChannelListQueryMessageFormat];
	
	return [rawMessage messageData];
}

@end
