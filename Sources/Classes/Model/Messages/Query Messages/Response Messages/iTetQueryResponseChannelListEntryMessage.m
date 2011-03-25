//
//  iTetQueryResponseChannelListEntryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/19/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetQueryResponseChannelListEntryMessage.h"
#import "iTetChannelListEntry.h"

@implementation iTetQueryResponseChannelListEntryMessage

- (id)initWithMessageTokens:(NSArray*)messageTokens
{
	// Check the length of the list of tokens
	if ([messageTokens count] != iTetQueryResponseChannelListEntryMessageTokenCount)
	{
		[self release];
		return nil;
	}
	
	// Attempt to read channel information from the tokens of the message
	// Channel name
	NSString* channelName = [messageTokens objectAtIndex:0];
	
	// Channel description (minus any HTML formatting)
	NSString* channelDescription = [NSString stringWithFormat:@"<p>%@</p>", [messageTokens objectAtIndex:1]];
	NSError* parseError = nil;
	NSXMLElement* html = [[[NSXMLElement alloc] initWithXMLString:channelDescription
															error:&parseError] autorelease];
	if (parseError != nil)
	{
		// If the description can't be parsed as HTML, treat it as unformatted text
		channelDescription = [messageTokens objectAtIndex:1];
		NSLog(@"WARNING: error parsing HTML formatting on description of channel '%@'", channelName);
		NSLog(@"         raw description: %@", channelDescription);
		NSLog(@"         error: %@", parseError);
	}
	else
	{
		// Convert to a raw string, stripping HTML formatting
		channelDescription = [html stringValue];
	}
	
	// Current/max player count
	NSInteger currentPlayerCount = [[messageTokens objectAtIndex:2] integerValue];
	NSInteger maxPlayerCount = [[messageTokens objectAtIndex:3] integerValue];
	
	// Channel priority (order in which players join as channels fill)
	NSInteger channelPriority = [[messageTokens objectAtIndex:4] integerValue];
	
	// Current gameplay state (in-game, paused, etc.)
	iTetGameplayState gameplayState = [[messageTokens objectAtIndex:5] intValue];
	
	// Create a channel-list-entry object from the information
	channelListEntry = [[iTetChannelListEntry alloc] initWithName:channelName
													  description:channelDescription
												   currentPlayers:currentPlayerCount
													   maxPlayers:maxPlayerCount
														 priority:channelPriority
															state:gameplayState];
	
	return self;
}

- (id)initWithChannelListEntry:(iTetChannelListEntry*)entry
{
	channelListEntry = [entry copy];
	
	return self;
}

- (void)dealloc
{
	[channelListEntry release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"\"%@\" \"%@\" %ld %ld %ld %d",
			[[self channelListEntry] channelName],
			[[self channelListEntry] channelDescription],
			(long)[[self channelListEntry] playerCount],
			(long)[[self channelListEntry] maxPlayerCount],
			(long)[[self channelListEntry] channelPriority],
			[[self channelListEntry] channelState]];
}

#pragma mark -
#pragma mark Accessors

@synthesize channelListEntry;

@end
