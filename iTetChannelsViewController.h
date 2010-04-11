//
//  iTetChannelsViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//

#import <Cocoa/Cocoa.h>

@class iTetChatViewController;
@class iTetPlayersController;
@class iTetWindowController;
@class iTetNetworkController;
@class iTetServerInfo;
@class AsyncSocket;

@interface iTetChannelsViewController : NSObject
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
	
	// Channel query socket
	AsyncSocket* querySocket;
	iTetServerInfo* currentServer;
	BOOL serverSupportsQueries;
	BOOL queryInProgess;
}

- (void)requestChannelListFromServer:(iTetServerInfo*)server;
- (IBAction)refreshChannelList:(id)sender;
- (void)stopQueriesAndDisconnect;
- (void)switchToChannelNamed:(NSString*)channelName;

@property (readonly) NSArray* channels;

@end
