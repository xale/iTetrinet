//
//  iTetNetworkContext.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/17/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetGameConnection;
@class iTetQueryConnection;
@class iTetServerInfo;
@class iTetOnlineGameContext;

@interface iTetNetworkContext : NSObject
{
	iTetGameConnection* gameConnection;	/*!< The connection communicating game and player state with the server. */
	iTetQueryConnection* queryConnection;	/*!< The connection receiving channel and additional player information from the server. */
	
	iTetServerInfo* server;	/*!< The server with which this context communicates. */
	
	iTetOnlineGameContext* gameContext;	/*!< The local representation of server/game state modified by this context. */
}

- (id)initWithServer:(iTetServerInfo*)serverToConnect
		 gameContext:(iTetOnlineGameContext*)context;

- (BOOL)connect;
- (void)disconnect;

@property (readonly) iTetServerInfo* server;
@property (readonly) BOOL connectionOpen;

@end
