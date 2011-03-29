//
//  iTetNetworkConnection.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/20/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNetworkConnection.h"

#import "iTetServerInfo.h"
#import "AsyncSocket.h"

#import "iTetMessage.h"
#import "NSString+MessageData.h"
#import "NSData+Subdata.h"

@implementation iTetNetworkConnection

- (id)initWithDelegate:(id<iTetNetworkConnectionDelegate>)connectionDelegate
	 connectedToServer:(iTetServerInfo*)serverToConnect
	   connectionError:(NSError**)error
{
	if (!(self = [super init]))
		return nil;
	
	// Hold a reference to the delegate, and retain the server
	delegate = connectionDelegate;
	server = [serverToConnect retain];
	
	// Create the socket and attempt to connect
	socket = [[AsyncSocket alloc] initWithDelegate:self];
	BOOL connectionSuccess = [socket connectToHost:[server serverAddress]
											onPort:[self connectionPort]
											 error:error];
	
	// If the connection fails, abort creation of this object
	if (!connectionSuccess)
	{
		[self release];
		return nil;
	}
	
	return self;
}

- (void)disconnect
{
	// If already disconnected, do nothing
	if (![socket isConnected])
		return;
	
	// Disconnect
	[socket disconnect];
}

- (void)dealloc
{
	// Disconnect, if necessary
	[self disconnect];
	
	[socket release];
	[server release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Messages

- (void)sendMessage:(iTetMessage*)message
{
	// Convert the message to a format suitable for sending
	NSMutableData* messageData = [NSMutableData dataWithData:[[message messageContents] messageData]];
	
	// Append an outgoing message terminator
	[messageData appendData:[self outgoingMessageTerminator]];
	
	// Send the message data
	[socket writeData:messageData
		  withTimeout:-1
				  tag:0];
}

- (void)receiveNextMessage
{
	// Tell the socket to read bytes up to the next message terminator
	[socket readDataToData:[self incomingMessageTerminator]
			   withTimeout:-1
					   tag:0];
}

- (iTetMessage*)messageFromData:(NSData*)data
{
	// Abstract method: throw an exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

#pragma mark -
#pragma mark AsyncSocket Delegate Methods

- (void)onSocket:(AsyncSocket*)sock
didConnectToHost:(NSString *)host
			port:(UInt16)port
{
	// Inform the delegate, if it is interested
	if ([delegate respondsToSelector:@selector(networkConnection:didConnectToHost:)])
	{
		[delegate networkConnection:self
				   didConnectToHost:host];
	}
}

- (void)onSocket:(AsyncSocket*)sock
	 didReadData:(NSData*)data
		 withTag:(long)tag
{
	// Trim the terminator off the message data
	data = [data subdataToIndex:([data length] - [[self incomingMessageTerminator] length])];
	
	// Attempt to create a message from the message data
	iTetMessage* message = [self messageFromData:data];
	
	// If the received data is a valid message, hand it to the delegate for processing
	[delegate networkConnection:self
			  didReceiveMessage:message];
}

- (void)onSocket:(AsyncSocket*)sock
willDisconnectWithError:(NSError*)err
{
	// If an error occurred, inform the delegate, if it wants to know
	if ((err != nil) && [delegate respondsToSelector:@selector(networkConnection:willDisconnectWithError:)])
	{
		[delegate networkConnection:self
			willDisconnectWithError:err];
	}
}

- (void)onSocketDidDisconnect:(AsyncSocket*)sock
{
	// Inform the delegate, if it is interested
	if ([delegate respondsToSelector:@selector(networkConnectionDidDisconnect:)])
		[delegate networkConnectionDidDisconnect:self];
}

#pragma mark -
#pragma mark Connection Information

- (UInt16)connectionPort
{
	// Abstract method: throw an exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (NSData*)incomingMessageTerminator
{
	// Abstract method: throw an exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSData*)outgoingMessageTerminator
{
	// Abstract method: throw an exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

#pragma mark -
#pragma mark Accessors

@synthesize server;

@end
