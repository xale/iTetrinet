//
//  iTetQueryConnection.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/17/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNetworkConnection.h"

@interface iTetQueryConnection : iTetNetworkConnection

/*!
 Convenience method. Generates and sends a channel-list-query message to the connected server.
 */
- (void)sendChannelQuery;
/*!
 Convenience method. Generates and sends a player-list-query message to the connected server.
 */
- (void)sendPlayerQuery;

@end
