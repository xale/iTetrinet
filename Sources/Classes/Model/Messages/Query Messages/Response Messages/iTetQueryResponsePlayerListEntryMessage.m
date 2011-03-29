//
//  iTetQueryResponsePlayerListEntryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/19/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetQueryResponsePlayerListEntryMessage.h"
#import "iTetPlayerListEntry.h"

@implementation iTetQueryResponsePlayerListEntryMessage

- (id)initWithMessageTokens:(NSArray*)messageTokens
{
	if (!(self = [super initWithMessageTokens:messageTokens]))
		return nil;
	
	// Check the length of the list of tokens
	if ([messageTokens count] != iTetQueryResponsePlayerListEntryMessageTokenCount)
	{
		[self release];
		return nil;
	}
	
	// Attempt to read player information from the tokens of the message
	// Nickname
	NSString* playerNickname = [messageTokens objectAtIndex:0];
	
	// Team name
	NSString* playerTeamName = [messageTokens objectAtIndex:1];
	
	// Client protocol version
	NSString* clientVersion = [messageTokens objectAtIndex:2];
	
	// Player number
	NSInteger playerNumber = [[messageTokens objectAtIndex:3] integerValue];
	
	// Current gameplay state
	iTetPlayerGameplayState gameplayState = [[messageTokens objectAtIndex:4] intValue];
	
	// Operator/administrator status
	NSInteger playerAuthLevel = [[messageTokens objectAtIndex:5] integerValue];
	
	// Channel name
	NSString* playerChannelName = [messageTokens objectAtIndex:6];
	
	// Create a player-list-entry object from the information
	playerListEntry = [[iTetPlayerListEntry alloc] initWithNickname:playerNickname
														   teamName:playerTeamName
														channelName:playerChannelName
													   playerNumber:playerNumber
														  authLevel:playerAuthLevel
													 gameplayStatus:gameplayState
													  clientVersion:clientVersion];
	
	return self;
}

- (id)initWithPlayerListEntry:(iTetPlayerListEntry*)entry
{
	if (!(self = [super init]))
		return nil;
	
	playerListEntry = [entry copy];
	
	return self;
}

- (void)dealloc
{
	[playerListEntry release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"\"%@\" \"%@\" \"%@\" %ld %d %ld \"%@\"",
			[[self playerListEntry] playerNickname],
			[[self playerListEntry] playerTeamName],
			[[self playerListEntry] clientVersion],
			(long)[[self playerListEntry] playerNumber],
			[[self playerListEntry] playerStatus],
			(long)[[self playerListEntry] playerAuthLevel],
			[[self playerListEntry] channelName]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerListEntry;

@end
