//
//  iTetOnlineGameContext.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGameContext.h"

@class iTetPlayer;

@interface iTetOnlineGameContext : iTetGameContext
{
	NSMutableArray* channelPlayers;	/*!< The list of players in the current channel. */
	NSMutableAttributedString* chatHistory;	/*!< The chat history for the context. */
	
	NSMutableSet* serverChannels;	/*!< The list of channels on the server, if available. */
	NSMutableSet* serverPlayers;	/*!< The list of all players on the server, if available. */
}

@property (readonly) NSArray* channelPlayers;
@property (readonly) NSAttributedString* chatHistory;
@property (readonly) NSArray* serverChannels;
@property (readonly) NSArray* serverPlayers;

@end
