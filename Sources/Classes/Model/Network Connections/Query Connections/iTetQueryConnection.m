//
//  iTetQueryConnection.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/17/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetQueryConnection.h"

#import "NSData+SingleByte.h"

#import "NSString+MessageData.h"
#import "NSString+QuotedComponents.h"

#import "iTetQueryChannelListRequestMessage.h"
#import "iTetQueryPlayerListRequestMessage.h"

#import "iTetQueryResponseTerminatorMessage.h"
#import "iTetQueryResponseChannelListEntryMessage.h"
#import "iTetQueryResponsePlayerListEntryMessage.h"

#define iTetQueryProtocolNetworkPort		(31457)
#define iTetQueryRequestMessageTerminator	(0xFF)
#define iTetQueryResponseMessageTerminator	(0x0A)

@implementation iTetQueryConnection

#pragma mark -
#pragma mark Messages

- (void)sendChannelQuery
{
	[self sendMessage:[iTetQueryChannelListRequestMessage message]];
}

- (void)sendPlayerQuery
{
	[self sendMessage:[iTetQueryPlayerListRequestMessage message]];
}

- (iTetMessage*)messageFromData:(NSData*)messageData
{
	// Convert the message to a string
	NSString* messageContents = [NSString stringWithMessageData:messageData];
	
	// Attempt to split the message into space-separated tokens, counting each quoted run as a single token
	NSArray* messageTokens = [messageContents quotedComponentsSeparatedByString:@" "
																	stripQuotes:YES];
	if (messageTokens == nil)
	{
		NSLog(@"WARNING: unbalanced quotes in message received by query-protocol connection: %@", messageContents);
		return nil;
	}
	
	// Determine the type of message based on (yes, really) the number of resulting tokens
	switch ([messageTokens count])
	{
			// One token: query-response terminator message
		case iTetQueryResponseTerminatorMessageTokenCount:
			return [iTetQueryResponseTerminatorMessage messageWithMessageTokens:messageTokens];
			
			// Six tokens: channel-list-entry message
		case iTetQueryResponseChannelListEntryMessageTokenCount:
			return [iTetQueryResponseChannelListEntryMessage messageWithMessageTokens:messageTokens];
			
			// Seven tokens: player-list-entry message
		case iTetQueryResponsePlayerListEntryMessageTokenCount:
			return [iTetQueryResponsePlayerListEntryMessage messageWithMessageTokens:messageTokens];
			
			// Other number of tokens: invalid message
		default:
			break;
	}
	
	// Unknown number of message tokens: log a warning
	NSLog(@"WARNING: invalid number of tokens in message received by query-protocol connection: %@", messageContents);
	return nil;
}

#pragma mark -
#pragma mark Connection Information

- (UInt16)connectionPort
{
	return iTetQueryProtocolNetworkPort;
}

- (NSData*)incomingMessageTerminator
{
	return [NSData dataWithByte:iTetQueryResponseMessageTerminator];
}

- (NSData*)outgoingMessageTerminator
{
	return [NSData dataWithByte:iTetQueryRequestMessageTerminator];
}

@end
