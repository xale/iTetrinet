//
//  iTetMessage+QueryMessageFactory.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage+QueryMessageFactory.h"

@implementation iTetMessage (QueryMessageFactory)

+ (iTetMessage<iTetIncomingMessage>*)queryMessageFromData:(NSData*)messageData
{
	// Attempt to parse the message as a query-response terminator
	iTetMessage<iTetIncomingMessage>* message = [iTetQueryResponseTerminatorMessage messageWithMessageData:messageData];
	if (message != nil)
		return message;
	
	// Attempt to parse the response as a channel list entry
	message = [iTetChannelListEntryMessage messageWithMessageData:messageData];
	if (message != nil)
		return message;
	
	// Attempt to parse the message as a player list entry
	message = [iTetPlayerListEntryMessage messageWithMessageData:messageData];
	
	return message;
}

@end
