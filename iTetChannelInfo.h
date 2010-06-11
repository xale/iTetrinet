//
//  iTetChannelInfo.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/23/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetGameplayState.h"

@interface iTetChannelInfo : NSObject
{
	NSString* channelName;
	NSAttributedString* channelDescription;
	NSInteger currentPlayers;
	NSInteger maxPlayers;
	iTetGameplayState channelState;
	BOOL localPlayerChannel;
}

+ (id)channelInfoWithName:(NSString*)name
			  description:(NSAttributedString*)desc
		   currentPlayers:(NSInteger)playerCount
			   maxPlayers:(NSInteger)max
					state:(iTetGameplayState)gameState;
- (id)initWithName:(NSString*)name
	   description:(NSAttributedString*)desc
	currentPlayers:(NSInteger)playerCount
		maxPlayers:(NSInteger)max
			 state:(iTetGameplayState)gameState;

@property (readonly) NSString* channelName;
@property (readonly) NSAttributedString* channelDescription;
@property (readonly) NSString* sortableDescription;
@property (readonly) NSString* players;
@property (readonly) NSNumber* sortablePlayers;
@property (readonly) iTetGameplayState channelState;
@property (readonly) NSNumber* sortableState;
@property (readwrite, assign, getter=isLocalPlayerChannel) BOOL localPlayerChannel;

@end
