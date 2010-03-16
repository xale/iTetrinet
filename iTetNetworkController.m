//
//  iTetNetworkController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import "iTetNetworkController.h"
#import "AsyncSocket.h"
#import "iTetServerInfo.h"

#import "iTetMessage+ClassFactory.h"
#import "iTetLoginMessage.h"

NSString* const iTetNetworkErrorDomain = @"iTetNetworkError";
#define iTetNetworkPort					(31457)
#define iTetNetworkTerminatorCharacter	(0xFF)

@interface iTetNetworkController (Private)

- (void)handleError:(NSError*)error;

@end


@implementation iTetNetworkController

- (id)init
{
	connectionSocket = [[AsyncSocket alloc] initWithDelegate:self];
	
	return self;
}

- (void)dealloc
{
	// Disconnect
	[self disconnect];
	
	// Release socket and server data
	[connectionSocket release];
	[currentServer release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Connecting

- (void)connectToServer:(iTetServerInfo*)server
{
	// Retain the server info
	currentServer = [server retain];
	
	// Open a connection to the server
	NSError* error;
	BOOL connectionSuccessful = [connectionSocket connectToHost:[currentServer address]
														 onPort:iTetNetworkPort
														  error:&error];
	
	// If the connection fails, determine the error
	if (!connectionSuccessful)
		[self handleError:error];
}

- (void)onSocket:(AsyncSocket*)socket
didConnectToHost:(NSString*)hostname
			port:(UInt16)port
{	
	// Create and send the server login message
	[self sendMessage:[iTetLoginMessage messageWithProtocol:[[self currentServer] protocol]
												   nickname:[[self currentServer] nickname]
													address:[socket connectedHost]]];
}

#pragma mark -
#pragma mark Disconnecting

- (void)disconnect
{
	// If we are already disconnected, ignore
	if (![connectionSocket isConnected])
		return;
	
	// Tell the sockect to disconnect
	[connectionSocket disconnectAfterWriting];
}

- (void)onSocket:(AsyncSocket*)socket
willDisconnectWithError:(NSError*)error
{
	// Handle the error as appropriate
	[self handleError:error];
}

- (void)onSocketDidDisconnect:(AsyncSocket*)socket
{
	// FIXME: WRITEME?
}

#pragma mark -
#pragma mark Reads/Writes

- (void)sendMessage:(iTetMessage<iTetOutgoingMessage>*)message
{
	// Send the message
	[connectionSocket writeData:[message rawMessageData]
					withTimeout:-1
							tag:0];
}

- (void)onSocket:(AsyncSocket*)socket
	 didReadData:(NSData*)data
		 withTag:(long)tag
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Errors

- (void)handleError:(NSError*)error
{	
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Accessors

@synthesize currentServer;

@end
