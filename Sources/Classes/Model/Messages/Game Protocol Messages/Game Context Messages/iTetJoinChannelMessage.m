//
//  iTetJoinChannelMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/29/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetJoinChannelMessage.h"

#import "iTetPartylineChatMessage.h"

#import "NSArray+Subranges.h"

NSString* const iTetJoinChannelCommandTag =	@"/join";

static NSString* const iTetChannelNamePrefixCharacter =	@"#";

@implementation iTetJoinChannelMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat the second token as the player number
	playerNumber = [[tokens objectAtIndex:1] integerValue];
	
	// Treat all tokens beyond the third as the channel name
	NSString* channel = [[tokens subarrayFromIndex:3] componentsJoinedByString:@" "];
	
	// Trim the channel-name prefix, if necessary
	if ([[channel substringToIndex:1] isEqualToString:iTetChannelNamePrefixCharacter])
		channelName = [[channel substringFromIndex:1] retain];
	else
		channelName = [channel retain];
	
	return self;
}

+ (id)messageWithPlayerNumber:(NSInteger)number
				  channelName:(NSString*)channel
{
	return [[[self alloc] initWithPlayerNumber:number
								   channelName:channel] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)number
			   channelName:(NSString*)channel
{
	if (!(self = [super init]))
		return nil;
	
	playerNumber = number;
	channelName = [channel copy];
	
	return self;
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %ld %@ %@%@", iTetPartylineChatMessageTag, (long)[self playerNumber], iTetJoinChannelCommandTag, iTetChannelNamePrefixCharacter, [self channelName]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize channelName;

@end
