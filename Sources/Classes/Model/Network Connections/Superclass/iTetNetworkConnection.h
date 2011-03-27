//
//  iTetNetworkConnection.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/20/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class AsyncSocket;
@class iTetServerInfo;
@class iTetMessage;

@protocol iTetNetworkConnectionDelegate;

@interface iTetNetworkConnection : NSObject
{
	id<iTetNetworkConnectionDelegate> delegate;
	
	AsyncSocket* socket;
	iTetServerInfo* server;
}

/*!
 Creates a new network connection with the specified delegate, and attempts to connect to the specified server, setting \c error if an error occurs in the initial phases of the connection.
 @param connectionDelegate The delegate to which connection events (such as received messages) are forwarded. Must not be nil.
 @param serverToConnect The server to which the connection should be established.
 @param error If not \c NULL, will be set to an appropriate error object if the connection cannot be set up.
 */
- (id)initWithDelegate:(id<iTetNetworkConnectionDelegate>)connectionDelegate
	 connectedToServer:(iTetServerInfo*)serverToConnect
	   connectionError:(NSError**)error;
- (void)disconnect;

/*!
 Sends the specified message to the server to which this connection is established.
 @param message The message to send.
 */
- (void)sendMessage:(iTetMessage*)message;
/*!
 Instructs the connection to read the next message from the server.
 */
- (void)receiveNextMessage;

/*!
 @warning Abstract method; subclasses must override.
 Creates a message object from data received from the server.
 @param data The data from which to construc the received message.
 */
- (iTetMessage*)messageFromData:(NSData*)data;

/*!
 @warning Abstract method; subclasses must override.
 Returns the network port over which the connection will attempt to communicate with the server.
 */
- (UInt16)connectionPort;
/*!
 @warning Abstract method; subclasses must override.
 Returns an NSData object containing the byte or bytes used to identify the end of an individual message from the server.
 */
- (NSData*)incomingMessageTerminator;
/*!
 @warning Abstract method; subclasses must override.
 Returns an NSData object containing the byte or bytes appended to the end of an outgoing message before transmission to the server.
 */
- (NSData*)outgoingMessageTerminator;

@property (readonly) iTetServerInfo* server;

@end

@protocol iTetNetworkConnectionDelegate <NSObject>

- (void)networkConnection:(iTetNetworkConnection*)connection
		didReceiveMessage:(iTetMessage*)message;

@optional

- (void)networkConnection:(iTetNetworkConnection*)connection
		 didConnectToHost:(NSString*)hostAddress;
- (void)networkConnection:(iTetNetworkConnection*)connection
  willDisconnectWithError:(NSError*)error;
- (void)networkConnectionDidDisconnect:(iTetNetworkConnection*)connection;

@end
