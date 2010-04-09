//
//  iTetMessage+ChannelMessageFactory.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//

#import "iTetMessage+ChannelMessageFactory.h"

@implementation iTetMessage (ChannelMessageFactory)

+ (iTetMessage<iTetIncomingMessage>*)channelMessageFromData:(NSData*)messageData
{
	// Attempt to parse the message as a query-response terminator
	iTetMessage<iTetIncomingMessage>* message = [iTetQueryResponseTerminatorMessage messageWithMessageData:messageData];
	if (message != nil)
		return message;
	
	// Attempt to parse the response as a channel list entry
	message = [iTetChannelListEntryMessage messageWithMessageData:messageData];
	
	return message;
}

@end
