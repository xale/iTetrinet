//
//  iTetNetworkController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@class iTetWindowController;
@class iTetPlayersController;
@class iTetGameViewController;
@class iTetChatViewController;
@class iTetWinlistViewController;

@class iTetServerInfo;
@class AsyncSocket;

extern NSString* const iTetNetworkErrorDomain;
typedef enum
{
	iTetNoConnectingError = 1
} iTetNetworkError;

typedef enum
{
	disconnected,
	connecting,
	login,
	connected,
	disconnecting,
	canceled,
	connectionError
} iTetConnectionState;

@interface iTetNetworkController : NSObject <NSUserInterfaceValidations>
{
	// Other top-level controllers
	IBOutlet iTetWindowController* windowController;
	IBOutlet iTetPlayersController* playersController;
	IBOutlet iTetGameViewController* gameController;
	IBOutlet iTetChatViewController* chatController;
	IBOutlet iTetWinlistViewController* winlistController;
	
	// Menu and toolbar items
	IBOutlet NSToolbarItem* connectionButton;
	IBOutlet NSMenuItem* connectionMenuItem;
	
	// Connection progress indicator
	IBOutlet NSProgressIndicator* connectionProgressIndicator;
	IBOutlet NSTextField* connectionStatusLabel;
	
	// List view (and controller) for servers on connection sheet
	IBOutlet NSScrollView* serverListView;
	IBOutlet NSArrayController* serverListController;
	
	// Network connection
	iTetServerInfo* currentServer;
	AsyncSocket* connectionSocket;
	iTetConnectionState connectionState;
}

- (IBAction)openCloseConnection:(id)sender;

- (void)connectToServer:(iTetServerInfo*)server;
- (void)disconnect;

- (void)sendMessage:(iTetMessage<iTetOutgoingMessage>*)message;

@property (readonly) NSString* currentServerAddress;
@property (readonly) iTetConnectionState connectionState;
@property (readonly) BOOL connectionOpen;

@end
