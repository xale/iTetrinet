//
//  iTetChannelsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetChannelsViewController.h"
#import "iTetChatViewController.h"
#import "iTetPlayersController.h"
#import "iTetWindowController.h"
#import "iTetNetworkController.h"

#import "iTetChannelInfo.h"

#import "IPSContextMenuTableView.h"

#import "iTetServerInfo.h"
#import "AsyncSocket.h"
#import "iTetMessage.h"
#import "iTetQueryMessage.h"

#import "iTetLocalPlayer.h"

#import "NSData+SingleByte.h"
#import "NSData+Subdata.h"
#import "NSDictionary+AdditionalTypes.h"
#import "NSString+MessageData.h"

#define iTetQueryNetworkPort			(31457)
#define iTetOutgoingQueryTerminator		(0xFF)
#define iTetIncomingResponseTerminator	(0x0A)

@interface iTetChannelsViewController (Private)

- (void)sendQueryMessage:(iTetQueryMessage*)message;
- (void)listenForResponse;

- (void)setChannels:(NSArray*)newChannels;
- (void)setLocalPlayerChannelName:(NSString*)channelName;

@end

@implementation iTetChannelsViewController

- (id)init
{
	querySocket = [[AsyncSocket alloc] initWithDelegate:self];
	updateChannels = [[NSMutableArray alloc] init];
	channels = [[NSArray alloc] init];
	localPlayerChannelName = [[NSString alloc] init];
	
	return self;
}

- (void)awakeFromNib
{
	// Set up the channels list double-click action
	[channelsTableView setTarget:self];
	[channelsTableView setDoubleAction:@selector(doubleClick)];
}

- (void)dealloc
{
	// Disconnect the query socket
	[querySocket disconnect];
	
	// De-register for notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[querySocket release];
	[currentServer release];
	[updateChannels release];
	[channels release];
	[localPlayerChannelName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

- (void)requestChannelListFromServer:(iTetServerInfo*)server
{
	// Hold a reference to the server
	currentServer = [server retain];
	
	// Assume, until we determine otherwise, that the server supports the Query protocol
	serverSupportsQueries = YES;
	
	// Attempt to open a Query-protocol connection to the server
	[querySocket connectToHost:[currentServer serverAddress]
						onPort:iTetQueryNetworkPort
						 error:NULL];
	
	// If the connection fails here, simply abort and retry when someone asks us to refresh the list; that being said, we shouldn't fail here very often, since this method should only be called after the network controller has already established a connection to the server over the game socket
}
	 
- (IBAction)refreshChannelList:(id)sender
{
	// If we already know that this server doesn't support the Query protocol, don't bother trying to refresh
	if (!serverSupportsQueries)
		return;
	
	// If we're not looking at the chat view tab, delay the refresh until the user switches
	if (![[[[windowController tabView] selectedTabViewItem] identifier] isEqualToString:iTetChatViewTabIdentifier])
		return;
	
	// If we already have a channel query pending or in progress, ignore the attempt to refresh
	if (channelQueryStatus != noQuery)
		return;
	
	// If we have a player query in progress, wait for it to complete before refreshing the channels
	if (playerQueryStatus == queryInProgress)
	{
		channelQueryStatus = pendingQuery;
		return;
	}
	
	// If we have been disconnected since the last query, (by a read timeout on the server's end, for instance) reconnect
	if (![querySocket isConnected])
	{
		[querySocket connectToHost:[currentServer serverAddress]
							onPort:iTetQueryNetworkPort
							 error:NULL];
		
		// Request will be sent automatically when the socket reopens
		return;
	}
	
	// If we are still connected, make an immediate request for the channel list
	[self sendQueryMessage:[iTetQueryMessage queryMessageWithMessageType:channelListQueryMessage]];
	channelQueryStatus = queryInProgress;
	
	// Listen for the query response
	[self listenForResponse];
}

- (IBAction)refreshLocalPlayerChannel:(id)sender
{
	// If we already know that this server doesn't support the Query protocol, don't bother trying to refresh
	if (!serverSupportsQueries)
		return;
	
	// If we already have a player query pending or in progress, ignore the attempt to refresh
	if (playerQueryStatus != noQuery)
		return;
	
	// If we have a channel query in progress, wait for it to complete
	if (channelQueryStatus == queryInProgress)
	{
		playerQueryStatus = pendingQuery;
		return;
	}
	
	// If we're not looking at the chat view tab, delay the refresh until the user switches
	if (![[[[windowController tabView] selectedTabViewItem] identifier] isEqualToString:iTetChatViewTabIdentifier])
	{
		playerQueryStatus = pendingQuery;
		return;
	}
	
	// If we have been disconnected since the last query, reconnect
	if (![querySocket isConnected])
	{
		[querySocket connectToHost:[currentServer serverAddress]
							onPort:iTetQueryNetworkPort
							 error:NULL];
		
		// Player query will be performed automatically (after a channel query)
		return;
	}
	
	// If we are still connected, make an immediate request for the channel list
	[self sendQueryMessage:[iTetQueryMessage queryMessageWithMessageType:playerListQueryMessage]];
	playerQueryStatus = queryInProgress;
	
	// Listen for the query response
	[self listenForResponse];
}

- (void)stopQueriesAndDisconnect
{
	// Disconnect the socket
	[querySocket disconnect];
	
	// De-register for tab-change notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// Clear the channel list
	[self setChannels:nil];
}

- (void)tabChanged:(NSNotification*)notification
{
	// If the chat tab is now active, refresh the channel list
	if ([[[[windowController tabView] selectedTabViewItem] identifier] isEqualToString:iTetChatViewTabIdentifier])
		[self refreshChannelList:self];
}

#pragma mark -
#pragma mark IPSContextMenuTableView Delegate Methods

#define iTetChannelRightClickActionsMenuTitle	NSLocalizedStringFromTable(@"Channel Actions", @"ChannelsViewController", @"Title of contextual menu displayed when the user right- or control-clicks on a channel in the channels list")
#define iTetJoinChannelActionMenuItemTitle		NSLocalizedStringFromTable(@"Join Channel", @"ChannelsViewController", @"Title of menu item in the contextual menu displayed when a user right- or control-clicks on a channel in the channels list that allows the user to join the clicked channel")

- (NSMenu*)tableView:(IPSContextMenuTableView*)tableView
		menuForEvent:(NSEvent*)event
{
	// Check that the table view has exactly one row selected
	if ([tableView numberOfSelectedRows] != 1)
		return nil;
	
	// Create a menu
	NSMenu* menu = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:iTetChannelRightClickActionsMenuTitle] autorelease];
	[menu setAutoenablesItems:NO];
	
	// Create "join channel" a menu item
	NSMenuItem* menuItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:iTetJoinChannelActionMenuItemTitle
																				 action:@selector(switchToSelectedChannel:)
																		  keyEquivalent:[NSString string]] autorelease];
	[menuItem setTarget:self];
	[menu addItem:menuItem];
	
	return menu;
}

#pragma mark -
#pragma mark Changing Channels

- (void)doubleClick
{
	// Check that the double-click was on a channel
	NSInteger row = [channelsTableView clickedRow];
	if ((row < 0) || (row >= (NSInteger)[channels count]))
		return;
	
	// Select the channel, and attempt to switch to it
	[channelsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
				   byExtendingSelection:NO];
	[self switchToSelectedChannel:self];
}

- (IBAction)switchToSelectedChannel:(id)sender
{
	// Get the name of the channel described in the clicked row
	NSString* channelName = [[[channelsArrayController arrangedObjects] objectAtIndex:[channelsTableView selectedRow]] channelName];
	
	// Attempt to switch to the channel
	[self switchToChannelNamed:channelName];	
}

#define iTetSwitchedChannelStatusMessageFormat	NSLocalizedStringFromTable(@"Switching to channel '%@'", @"ChannelsViewController", @"Status message appended to the chat view when the user changes channels on the server to which he or she is connected")

- (void)switchToChannelNamed:(NSString*)channelName
{
	// Check that the player is not already in this channel
	if ([channelName isEqualToString:localPlayerChannelName])
		return;
	
	// Append a status message to the chat view
	[chatController appendStatusMessage:[NSString stringWithFormat:iTetSwitchedChannelStatusMessageFormat, channelName]];
	
	// Create a "/join <channelname>" chat message
	iTetMessage* joinMessage = [iTetMessage messageWithMessageType:joinChannelMessage];
	[[joinMessage contents] setInteger:[[playersController localPlayer] playerNumber]
								forKey:iTetMessagePlayerNumberKey];
	[[joinMessage contents] setObject:channelName
							   forKey:iTetMessageChannelNameKey];
	
	// Send the message to the server (over the Tetrinet protocol, rather than as a query)
	[networkController sendMessage:joinMessage];
}

#pragma mark -
#pragma mark Queries

- (void)sendQueryMessage:(iTetQueryMessage*)message
{
	NSData* messageData = [message rawMessageData];
#ifdef _ITETRINET_DEBUG
	NSLog(@"DEBUG:       sending query message: '%@'", [NSString stringWithMessageData:messageData]);
#endif
	
	// Append a terminator byte and enqueue the message for sending
	[querySocket writeData:[messageData dataByAppendingByte:iTetOutgoingQueryTerminator]
			   withTimeout:-1
					   tag:0];
}

- (void)listenForResponse
{
	// Ask the socket to call us back when it sees a query-response message terminator
	[querySocket readDataToData:[NSData dataWithByte:iTetIncomingResponseTerminator]
					withTimeout:-1
							tag:0];
}

#pragma mark -
#pragma mark AsyncSocket Delegate Methods

- (void)onSocket:(AsyncSocket*)socket
didConnectToHost:(NSString*)host
			port:(UInt16)port
{
	// Make the initial request the for channel list
	[self sendQueryMessage:[iTetQueryMessage queryMessageWithMessageType:channelListQueryMessage]];
	channelQueryStatus = queryInProgress;
	
	// Perform a player list query when the channel query finishes
	playerQueryStatus = pendingQuery;
	
	// Listen for the query response
	[self listenForResponse];
	
	// Register for notifications when the selected tab of the main window changes, to refresh the channel list
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tabChanged:)
												 name:iTetWindowControllerSelectedTabViewItemDidChangeNotification
											   object:nil];
}

- (void)onSocket:(AsyncSocket*)socket
	 didReadData:(NSData*)data
		 withTag:(long)tag
{
	// If we have determined that the server doesn't support the query protocol, don't bother reading the message
	if (!serverSupportsQueries)
		return;
	
	// Trim the terminator character from the end of the data
	data = [data subdataToIndex:([data length] - 1)];
	
#ifdef _ITETRINET_DEBUG
	NSLog(@"DEBUG: query message data received: '%@'", [NSString stringWithMessageData:data]);
#endif
	
	// Attempt to parse the data as a Query response message
	iTetQueryMessage* message = [iTetQueryMessage queryMessageWithMessageData:data];
	
	// If the message is not a valid Query response, abort the attempt to retrieve channels
	if (message == nil)
	{
		serverSupportsQueries = NO;
		channelQueryStatus = noQuery;
		playerQueryStatus = noQuery;
		[querySocket disconnect];
		return;
	}
	
	// Otherwise, determine the nature of the message
	switch ([message type])
	{
		case channelListEntryMessage:
		{
			// Create a new entry for the channel list
			NSDictionary* info = [message contents];
			iTetChannelInfo* channel = [iTetChannelInfo channelInfoWithName:[info objectForKey:iTetMessageChannelNameKey]
																description:[info objectForKey:iTetQueryMessageChannelDescriptionKey]
															 currentPlayers:[info integerForKey:iTetQueryMessageChannelPlayerCountKey]
																 maxPlayers:[info integerForKey:iTetQueryMessageChannelMaxPlayersKey]
																	  state:[info intForKey:iTetQueryMessageGameplayStateKey]];
			
			// Check if the channel is the local player's
			if ([[channel channelName] isEqualToString:localPlayerChannelName])
				[channel setLocalPlayerChannel:YES];
			
			// Add the entry to a temporary list
			[updateChannels addObject:channel];
			
			// Continue listening for reply messages
			[self listenForResponse];
			
			break;
		}
		case playerListEntryMessage:
		{
			// Check if the entry corresponds to the local player
			if ([[[message contents] objectForKey:iTetMessagePlayerNicknameKey] isEqualToString:[[playersController localPlayer] nickname]])
			{
				// Change the which channel is recognized as the local player's
				[self setLocalPlayerChannelName:[[message contents] objectForKey:iTetMessageChannelNameKey]];
			}
			
			// Continue listening for reply messages
			[self listenForResponse];
			
			break;
		}
		case queryResponseTerminatorMessage:
		{
			// Determine whether this is the end of a player list or a channels list
			if (channelQueryStatus == queryInProgress)
			{
				channelQueryStatus = noQuery;
				
				// Signals the end of the list of channels; finalize the list
				[self setChannels:updateChannels];
				
				// Clear the temporary list
				[updateChannels removeAllObjects];
				
				// If necessary, begin a player list request
				if (playerQueryStatus == pendingQuery)
				{
					[self sendQueryMessage:[iTetQueryMessage queryMessageWithMessageType:playerListQueryMessage]];
					playerQueryStatus = queryInProgress;
					[self listenForResponse];
				}
			}
			else if (playerQueryStatus == queryInProgress)
			{
				playerQueryStatus = noQuery;
				
				// If necessary, begin a new channel list request
				if (channelQueryStatus == pendingQuery)
				{
					[self sendQueryMessage:[iTetQueryMessage queryMessageWithMessageType:channelListQueryMessage]];
					channelQueryStatus = queryInProgress;
					[self listenForResponse];
				}
			}
			else
			{
				NSLog(@"warning: query-response-terminator received with no query in-progress");
			}
			
			break;
		}	
		default:
		{
			NSAssert2(NO, @"invalid message type detected in ChannelsViewController: %d; contents: %@", [message type], [message contents]);
			break;
		}
	}
}

- (void)onSocket:(AsyncSocket*)socket
willDisconnectWithError:(NSError*)error
{
	// If an error occurred, abort quietly, but make note that the server doesn't support the Query protocol
	if (error != nil)
		serverSupportsQueries = NO;
}

- (void)onSocketDidDisconnect:(AsyncSocket*)socket
{
	channelQueryStatus = noQuery;
	playerQueryStatus = noQuery;
}

#pragma mark -
#pragma mark Accessors

- (void)setChannels:(NSArray*)newChannels
{
	[self willChangeValueForKey:@"channels"];
	
	// Copy the new list of channels
	newChannels = [newChannels copy];
	
	// Release the old list
	[channels release];
	
	// Swap the old list for the new
	channels = newChannels;
	
	[self didChangeValueForKey:@"channels"];
}
@synthesize channels;

- (void)setLocalPlayerChannelName:(NSString*)channelName
{
	// Disallow nil channel names
	if (channelName == nil)
		channelName = [NSString string];
	
	// If the name isn't changing, do nothing (fail-fast optimization)
	if ([localPlayerChannelName isEqualToString:channelName])
		return;
	
	[self willChangeValueForKey:@"channels"];
	
	// Attempt to un-mark the player's previous channel
	NSArray* filteredChannels = [channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"channelName == %@", localPlayerChannelName]];
	for (iTetChannelInfo* channel in filteredChannels)
		[channel setLocalPlayerChannel:NO];
	
	// Find and mark the player's new channel
	filteredChannels = [channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"channelName == %@", channelName]];
	if ([filteredChannels count] > 0)
	{
		if ([filteredChannels count] > 1)
			NSLog(@"warning: multiple channels named '%@' on this server", channelName);
		
		[[filteredChannels objectAtIndex:0] setLocalPlayerChannel:YES];
	}
	else
	{
		NSLog(@"warning: no channels named '%@' on this server", channelName);
	}
	
	[self didChangeValueForKey:@"channels"];
	
	[self willChangeValueForKey:@"localPlayerChannelName"];
	
	// We don't need to bother with the "retain first" business, since we've already eliminated the possibility that this is the same object
	[localPlayerChannelName release];
	localPlayerChannelName = [channelName retain];
	
	[self didChangeValueForKey:@"localPlayerChannelName"];
}
@synthesize localPlayerChannelName;

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	if ([key isEqualToString:@"channels"])
		return NO;
	
	if ([key isEqualToString:@"localPlayerChannelName"])
		return NO;
	
	return [super automaticallyNotifiesObserversForKey:key];
}

@end
