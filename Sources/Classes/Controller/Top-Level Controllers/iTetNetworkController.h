//
//  iTetNetworkController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"
#import "iTetServerListEntry.h"

@class iTetWindowController;
@class iTetPlayersController;
@class iTetGameViewController;
@class iTetChatViewController;
@class iTetChannelsViewController;
@class iTetWinlistViewController;

@class AsyncSocket;

@class iTetLocalPlayer;

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
	IBOutlet iTetChannelsViewController* channelsController;
	IBOutlet iTetWinlistViewController* winlistController;
	
	// Menu and toolbar items
	IBOutlet NSToolbarItem* connectionButton;
	IBOutlet NSMenuItem* connectionMenuItem;
	
	// Connection progress indicator
	IBOutlet NSProgressIndicator* connectionProgressIndicator;
	IBOutlet NSTextField* connectionStatusLabel;
	
	// Network connection
	AsyncSocket* gameSocket;
	iTetConnectionState connectionState;
	NSString* currentServerAddress;
	iTetProtocolType currentServerProtocol;
	iTetGameVersion currentGameVersion;
	iTetLocalPlayer* connectingPlayer;
}

- (IBAction)openCloseConnection:(id)sender;

- (void)connectToServerAddress:(NSString*)serverAddress
					  protocol:(iTetProtocolType)gameProtocol
					   version:(iTetGameVersion)gameVersion
				playerNickname:(NSString*)nickname
				playerTeamName:(NSString*)teamName;
- (void)disconnect;

- (void)sendMessage:(iTetMessage*)message;

@property (readonly) NSString* currentServerAddress;
@property (readonly) iTetConnectionState connectionState;
@property (readonly) BOOL connectionOpen;

@end
