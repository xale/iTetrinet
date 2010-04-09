//
//  iTetChannelsViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//

#import <Cocoa/Cocoa.h>

@class iTetChatViewController;
@class iTetServerInfo;
@class AsyncSocket;

@interface iTetChannelsViewController : NSObject
{
	// Top-level controllers
	IBOutlet iTetChatViewController* chatController;
	
	// Interface elements
	IBOutlet NSTableView* channelsTableView;
	
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

@property (readonly) NSArray* channels;

@end
