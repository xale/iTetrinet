//
//  iTetNetworkController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import <Cocoa/Cocoa.h>

@class iTetServerInfo;
@class Queue;

extern NSString* const iTetNetworkErrorDomain;
typedef enum
{
	iTetNoConnectingError = 1
} iTetNetworkError;

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
- (void)initializeConnection;
- (void)disconnect;

- (void)attemptRead;
- (void)attemptWrite;
- (void)handleError:(NSStream*)stream;
- (void)sendMessage:(NSString*)message;

@property (readonly) iTetServerInfo* currentServer;
@property (readwrite, assign) BOOL connected;

@end
