//
//  iTetGameConnection.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/17/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGameConnection.h"

#import "NSData+SingleByte.h"
#import "NSString+MessageData.h"
#import "iTetHeartbeatMessage.h"

#define iTetTetrinetProtocolNetworkPort			(31457)
#define iTetTetrinetProtocolMessageTerminator	(0xFF)

@implementation iTetGameConnection

#pragma mark -
#pragma mark Messages

- (iTetMessage*)messageFromData:(NSData*)data
{
	// If the message is blank, this is a special-case "heartbeat" message
	if ([data length] == 0)
		return [iTetHeartbeatMessage message];
	
	// Convert the data to a string, and split into space-separated tokens
	NSArray* tokens = [[NSString stringWithMessageData:data] componentsSeparatedByString:@" "];
	
	// Get the class of message based on the message's tag (the first word of the message)
	NSString* messageTag = [tokens objectAtIndex:0];
	Class messageClass = [[self messageTypesByTag] objectForKey:messageTag];
	
	// Instantiate and return a message of the given class
	return [messageClass messageWithMessageTokens:tokens];
}

- (NSDictionary*)messageTypesByTag
{
	// Abstract method; throw exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

#pragma mark -
#pragma mark Connection Information

- (UInt16)connectionPort
{
	return iTetTetrinetProtocolNetworkPort;
}

- (NSData*)incomingMessageTerminator
{
	return [NSData dataWithByte:iTetTetrinetProtocolMessageTerminator];
}

- (NSData*)outgoingMessageTerminator
{
	return [NSData dataWithByte:iTetTetrinetProtocolMessageTerminator];
}

@end
