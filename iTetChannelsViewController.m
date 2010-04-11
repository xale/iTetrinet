//
//  iTetChannelsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//

#import "iTetChannelsViewController.h"
#import "iTetChatViewController.h"
#import "iTetWindowController.h"

#import "iTetChannelInfo.h"

#import "iTetServerInfo.h"
#import "AsyncSocket.h"

#import "iTetMessage+ChannelMessageFactory.h"
#import "iTetChannelListQueryMessage.h"
#import "iTetChannelListEntryMessage.h"

#import "NSString+MessageData.h"
#import "NSData+SingleByte.h"
#import "NSData+Subdata.h"

#define iTetQueryNetworkPort			(31457)
#define iTetOutgoingQueryTerminator		(0xFF)
#define iTetIncomingResponseTerminator	(0x0A)

@interface iTetChannelsViewController (Private)

- (void)sendQueryMessage;
- (void)listenForResponse;

- (void)setChannels:(NSArray*)newChannels;

@end


@implementation iTetChannelsViewController

- (id)init
{
	querySocket = [[AsyncSocket alloc] initWithDelegate:self];
	updateChannels = [[NSMutableArray alloc] init];
	
	return self;
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
	[querySocket connectToHost:[currentServer address]
						onPort:iTetQueryNetworkPort
						 error:NULL];
	
	// If the connection fails here, simply abort and retry when someone asks us to refresh the list; that being said, we shouldn't fail here very often, since this method should only be called after the network controller has already established a connection to the server over the game socket
}
	 
- (IBAction)refreshChannelList:(id)sender
{
	// If we already know that this server doesn't support the Query protocol, don't bother trying to refresh
	if (!serverSupportsQueries)
		return;
	
	// If we already have a query in progress, ignore the attempt to refresh
	if (queryInProgess)
		return;
	
	// If we're not looking at the chat view tab, delay the refresh until the user switches
	if (![[[[windowController tabView] selectedTabViewItem] identifier] isEqualToString:iTetChatViewTabIdentifier])
		return;
	
	// If we have been disconnected since the last query, (by a read timeout on the server's end, for instance) reconnect
	if (![querySocket isConnected])
	{
		[querySocket connectToHost:[currentServer address]
							onPort:iTetQueryNetworkPort
							 error:NULL];
		
		// Request will be sent automatically when the socket reopens
		return;
	}
	
	// Make a fresh request for the channel list
	[self sendQueryMessage];
	
	// Listen for the response
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
#pragma mark Channel Queries

- (void)sendQueryMessage
{
	NSData* messageData = [[iTetChannelListQueryMessage message] rawMessageData];
	NSLog(@"DEBUG:       sending query message: '%@'", [NSString stringWithMessageData:messageData]);
	
	// Enqueue a channel-list query message
	[querySocket writeData:[messageData dataByAppendingByte:iTetOutgoingQueryTerminator]
			   withTimeout:-1
					   tag:0];
	queryInProgess = YES;
}

- (void)listenForResponse
{
	// Start listening for reply messages
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
	// FIXME: debug logging
	NSLog(@"DEBUG: query socket open to host: %@", host);
	
	// Request the channel list
	[self sendQueryMessage];
	
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
	
	// FIXME: debug logging
	NSLog(@"DEBUG: query message data received: '%@'", [NSString stringWithMessageData:data]);
	
	// Parse the message data _after_ this method returns
	// The channel description is formatted with HTML, which must be parsed by NSAttributedString's initWithHTML: methods. These methods fork the execution into another thread, which may cause the socket to call this callback again before the parsing is finished, resulting in the socket's buffer not being flushed properly. By returning from this method before attempting to parse the data, we ensure that the socket's buffer is flushed before the next read is attempted.
	[self performSelector:@selector(parseMessageData:)
			   withObject:data
			   afterDelay:0.0];
}

- (void)parseMessageData:(NSData*)messageData
{
	// Attempt to parse the data as a Query response message
	iTetMessage* message = [iTetMessage channelMessageFromData:messageData];
	
	// If the message is not a valid Query response, abort the attempt to retrieve channels
	if (message == nil)
	{
		serverSupportsQueries = NO;
		queryInProgess = NO;
		[querySocket disconnect];
		return;
	}
	
	// Otherwise, determine the nature of the message
	switch ([message messageType])
	{
		case channelListEntryMessage:
		{
			// Create a new entry for the channel list
			iTetChannelListEntryMessage* channelMessage = (iTetChannelListEntryMessage*)message;
			iTetChannelInfo* channel = [iTetChannelInfo channelInfoWithName:[channelMessage channelName]
																description:[channelMessage channelDescription]
															 currentPlayers:[channelMessage playerCount]
																 maxPlayers:[channelMessage maxPlayers]
																	  state:[channelMessage gameState]];
			
			// Add the entry to a temporary list
			[updateChannels addObject:channel];
			
			// Continue listening for reply messages
			[self listenForResponse];
			
			break;
		}
		case queryResponseTerminatorMessage:
		{
			// Signals the end of the list of channels; finalize the list
			[self setChannels:updateChannels];
			
			// Clear the temporary list
			[updateChannels removeAllObjects];
			
			// Leave ourselves connected, but do not continue reading; we're done until we're asked to refresh
			queryInProgess = NO;
			
			break;
		}	
		default:
			NSLog(@"WARNING: invalid message type detected in channel view controller: '%d'", [message messageType]);
			break;
	}
}

- (void)onSocket:(AsyncSocket*)socket
willDisconnectWithError:(NSError*)error
{
	// FIXME: debug logging
	NSLog(@"DEBUG: query socket will disconnect with error: %@", error);
	
	// If an error occurred, abort quietly, but make note that the server doesn't support the Query protocol
	if (error != nil)
		serverSupportsQueries = NO;
}

- (void)onSocketDidDisconnect:(AsyncSocket*)socket
{
	// FIXME: debug logging
	NSLog(@"DEBUG: query socket has disconnected");
	
	queryInProgess = NO;
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

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	if ([key isEqualToString:@"channels"])
		return NO;
	
	return [super automaticallyNotifiesObserversForKey:key];
}

@end
