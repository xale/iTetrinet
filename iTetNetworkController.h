//
//  iTetNetworkController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@class iTetServerInfo;
@class AsyncSocket;

extern NSString* const iTetNetworkErrorDomain;
typedef enum
{
	iTetNoConnectingError = 1
} iTetNetworkError;

@interface iTetNetworkController : NSObject
{
	// Other top-level controllers
	iTetPlayersController* playersController;
	iTetGameViewController* gameController;
	iTetChatViewController* chatController;
	iTetWinlistViewController* winlistController;
	
	// Network-related
	iTetServerInfo* currentServer;
	AsyncSocket* connectionSocket;
}

- (void)connectToServer:(iTetServerInfo*)server;
- (void)disconnect;

- (void)sendMessage:(iTetMessage<iTetOutgoingMessage>*)message;

@property (readonly) iTetServerInfo* currentServer;

@end
