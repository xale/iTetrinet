//
//  iTetTetrinetGameConnection.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetTetrinetGameConnection.h"

#import "iTetNoConnectingMessage.h"

#import "iTetTetrinetPlayerNumberMessage.h"
#import "iTetPlayerJoinMessage.h"
#import "iTetPlayerLeaveMessage.h"
#import "iTetPlayerKickMessage.h"
#import "iTetPlayerTeamMessage.h"
#import "iTetWinlistMessage.h"
#import "iTetPartylineChatMessage.h"
#import "iTetPartylineActionMessage.h"
#import "iTetGameChatMessage.h"

#import "iTetTetrinetNewGameMessage.h"
#import "iTetPlayerLevelMessage.h"

static NSDictionary* tetrinetMessageDictionary =	nil;

@interface iTetTetrinetGameConnection(Private)

- (NSDictionary*)tetrinetMessageDictionary;

@end

@implementation iTetTetrinetGameConnection

- (NSDictionary*)messageTypesByTag
{
	@synchronized(self)
	{
		if (tetrinetMessageDictionary == nil)
		{
			tetrinetMessageDictionary = [[self tetrinetMessageDictionary] copy];
		}
	}
	
	return tetrinetMessageDictionary;
}

- (NSDictionary*)tetrinetMessageDictionary
{
	// Create a dictionary, and add the standard tetrinet protocol messages to it
	NSMutableDictionary* messages = [NSMutableDictionary dictionary];
	
	// Connection status messages
	[messages setObject:[iTetNoConnectingMessage class]
				 forKey:iTetNoConnectingMessageTag];
	// Client-info-request messages use the player-level message tag
	
	// Game context messages
	[messages setObject:[iTetTetrinetPlayerNumberMessage class]
				 forKey:iTetTetrinetPlayerNumberMessageTag];
	[messages setObject:[iTetPlayerJoinMessage class]
				 forKey:iTetPlayerJoinMessageTag];
	[messages setObject:[iTetPlayerLeaveMessage class]
				 forKey:iTetPlayerLeaveMessageTag];
	[messages setObject:[iTetPlayerKickMessage class]
				 forKey:iTetPlayerKickMessageTag];
	[messages setObject:[iTetPlayerTeamMessage class]
				 forKey:iTetPlayerTeamMessageTag];
	[messages setObject:[iTetWinlistMessage class]
				 forKey:iTetWinlistMessageTag];
	[messages setObject:[iTetPartylineChatMessage class]
				 forKey:iTetPartylineChatMessageTag];
	[messages setObject:[iTetPartylineActionMessage class]
				 forKey:iTetPartylineActionMessageTag];
	[messages setObject:[iTetGameChatMessage class]
				 forKey:iTetGameChatMessageTag];
	
	// Gameplay messages
	[messages setObject:[iTetTetrinetNewGameMessage class]
				 forKey:iTetTetrinetNewGameMessageTag];
	[messages setObject:[iTetPlayerLevelMessage class]
				 forKey:iTetPlayerLevelMessageTag];
	// FIXME: WRITEME
	
	return messages;
}

@end
