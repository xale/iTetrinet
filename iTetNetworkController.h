//
//  iTetNetworkController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@class iTetServerInfo;
@class Queue;

extern NSString* const iTetNetworkErrorDomain;
typedef enum
{
	iTetNoConnectingError = 1
} iTetNetworkError;

@interface NSObject (iTetNetworkControllerDelegate)

- (void)connectionOpened;
- (void)connectionClosed;
- (void)connectionError:(NSError*)error;
- (void)messageReceived:(iTetMessage<iTetIncomingMessage>*)message;

@end

@interface iTetNetworkController : NSObject
{
	id delegate;
	
	iTetServerInfo* currentServer;
	NSHost* currentConnection;
	BOOL connected;
	
	NSInputStream* readStream;
	NSMutableData* partialRead;
	
	NSOutputStream* writeStream;
	Queue* writeQueue;
}

- (id)initWithDelegate:(id)theDelegate;

- (void)connectToServer:(iTetServerInfo*)server;
- (void)disconnect;

- (void)sendMessage:(iTetMessage<iTetOutgoingMessage>*)message;
- (void)sendMessageData:(NSData*)messageData;

- (void)attemptRead;
- (void)attemptWrite;
- (void)handleError:(NSStream*)stream;

@property (readonly) iTetServerInfo* currentServer;
@property (readwrite, assign) BOOL connected;

@end
