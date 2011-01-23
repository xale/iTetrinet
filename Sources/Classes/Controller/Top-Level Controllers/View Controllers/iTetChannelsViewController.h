//
//  iTetChannelsViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetChatViewController;
@class iTetPlayersController;
@class iTetWindowController;
@class iTetNetworkController;
@class iTetServerInfo;
@class AsyncSocket;

typedef enum
{
	noQuery = 0,
	pendingQuery,
	queryInProgress
} iTetQueryStatus;

@interface iTetChannelsViewController : NSObject <NSUserInterfaceValidations>
{
	// Top-level controllers
	IBOutlet iTetChatViewController* chatController;
	IBOutlet iTetPlayersController* playersController;
	IBOutlet iTetWindowController* windowController;
	IBOutlet iTetNetworkController* networkController;
	
	// Interface Builder elements
	IBOutlet NSTableView* channelsTableView;
	IBOutlet NSArrayController* channelsArrayController;
	
	// Channels
	NSMutableArray* updateChannels;
	NSArray* channels;
	NSString* localPlayerChannelName;
	
	// Server query socket
	AsyncSocket* querySocket;
	iTetServerInfo* currentServer;
	BOOL serverSupportsQueries;
	iTetQueryStatus channelQueryStatus;
	iTetQueryStatus playerQueryStatus;
}

- (void)requestChannelListFromServer:(iTetServerInfo*)server;
- (IBAction)refreshChannelList:(id)sender;
- (void)stopQueriesAndDisconnect;

- (IBAction)switchToSelectedChannel:(id)sender;
- (void)switchToChannelNamed:(NSString*)channelName;

@property (readonly) NSArray* channels;
@property (readonly) NSString* localPlayerChannelName;

@end
