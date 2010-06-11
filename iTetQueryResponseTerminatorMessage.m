//
//  iTetQueryResponseTerminatorMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetQueryResponseTerminatorMessage.h"
#import "NSString+MessageData.h"

@implementation iTetQueryResponseTerminatorMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

NSString* const iTetQueryResponseTerminatorMessageFormat =	@"+OK";

- (id)initWithMessageData:(NSData*)messageData
{
	// Determine if this message is a terminator message
	if (![[NSString stringWithMessageData:messageData] isEqualToString:iTetQueryResponseTerminatorMessageFormat])
	{
		[self release];
		return nil;
	}
	
	messageType = queryResponseTerminatorMessage;
	
	return self;
}

@end
