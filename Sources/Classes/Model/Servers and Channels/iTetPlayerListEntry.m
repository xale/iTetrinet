//
//  iTetPlayerListEntry.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/19/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerListEntry.h"

@implementation iTetPlayerListEntry

+ (id)playerListEntryForPlayerWithNickname:(NSString*)nickname
								  teamName:(NSString*)teamName
							   channelName:(NSString*)channel
							  playerNumber:(NSInteger)number
								 authLevel:(NSInteger)authLevel
							gameplayStatus:(iTetPlayerGameplayState)gameplayStatus
							 clientVersion:(NSString*)version
{
	return [[[self alloc] initWithNickname:nickname
								  teamName:teamName
							   channelName:channel
							  playerNumber:number
								 authLevel:authLevel
							gameplayStatus:gameplayStatus
							 clientVersion:version] autorelease];
}
- (id)initWithNickname:(NSString*)nickname
			  teamName:(NSString*)teamName
		   channelName:(NSString*)channel
		  playerNumber:(NSInteger)number
			 authLevel:(NSInteger)authLevel
		gameplayStatus:(iTetPlayerGameplayState)gameplayStatus
		 clientVersion:(NSString*)version
{
	playerNickname = [nickname copy];
	playerTeamName = [teamName copy];
	channelName = [channel copy];
	playerNumber = number;
	playerAuthLevel = authLevel;
	playerStatus = gameplayStatus;
	clientVersion = [version copy];
	
	return self;
}

- (void)dealloc
{
	[playerNickname release];
	[playerTeamName release];
	[channelName release];
	[clientVersion release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
	return [[[self class] allocWithZone:zone] initWithNickname:[self playerNickname]
													  teamName:[self playerTeamName]
												   channelName:[self channelName]
												  playerNumber:[self playerNumber]
													 authLevel:[self playerAuthLevel]
												gameplayStatus:[self playerStatus]
												 clientVersion:[self clientVersion]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNickname;
@synthesize playerTeamName;
@synthesize channelName;
@synthesize playerNumber;
@synthesize playerAuthLevel;
@synthesize playerStatus;
@synthesize clientVersion;

@end
