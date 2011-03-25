//
//  iTetPlayerListEntry.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/19/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetGameplayState.h"

@interface iTetPlayerListEntry : NSObject <NSCopying>
{
	NSString* playerNickname;
	NSString* playerTeamName;
	NSString* channelName;
	NSInteger playerNumber;
	NSInteger playerAuthLevel;
	iTetPlayerGameplayState playerStatus;
	NSString* clientVersion;
}

+ (id)playerListEntryForPlayerWithNickname:(NSString*)nickname
								  teamName:(NSString*)teamName
							   channelName:(NSString*)channel
							  playerNumber:(NSInteger)number
								 authLevel:(NSInteger)authLevel
							gameplayStatus:(iTetPlayerGameplayState)gameplayStatus
							 clientVersion:(NSString*)version;
- (id)initWithNickname:(NSString*)nickname
			  teamName:(NSString*)teamName
		   channelName:(NSString*)channel
		  playerNumber:(NSInteger)number
			 authLevel:(NSInteger)authLevel
		gameplayStatus:(iTetPlayerGameplayState)gameplayStatus
		 clientVersion:(NSString*)version;

@property (readonly) NSString* playerNickname;
@property (readonly) NSString* playerTeamName;
@property (readonly) NSString* channelName;
@property (readonly) NSInteger playerNumber;
@property (readonly) NSInteger playerAuthLevel;
@property (readonly) iTetPlayerGameplayState playerStatus;
@property (readonly) NSString* clientVersion;

@end
