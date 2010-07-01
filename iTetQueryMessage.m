//
//  iTetQueryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/26/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetQueryMessage.h"
#import "iTetMessage.h"

#import "NSDictionary+AdditionalTypes.h"
#import "NSString+MessageData.h"
#import "NSString+QuotedComponents.h"

#pragma mark Message Formats

NSString* const iTetChannelListQueryMessageFormat =			@"listchan";
NSString* const iTetPlayerListQueryMessageFormat =			@"listuser";
NSString* const iTetQueryResponseTerminatorMessageFormat =	@"+OK";

#pragma mark -
#pragma mark Message Contents Keys

NSString* const iTetQueryMessageChannelDescriptionKey =	@"iTetChannelDescription";
NSString* const iTetQueryMessageChannelPlayerCountKey =	@"iTetChannelPlayerCount";
NSString* const iTetQueryMessageChannelMaxPlayersKey =	@"iTetChannelMaxPlayers";
NSString* const iTetQueryMessageChannelPriorityKey =	@"iTetChannelPriority";
NSString* const iTetQueryMessageGameplayStateKey =		@"iTetGameplayState";
NSString* const iTetQueryMessagePlayerAuthLevelKey =	@"iTetPlayerAuthLevel";

@implementation iTetQueryMessage

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

- (void)dealloc
{
	[contents release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Outgoing Message Constructor

+ (id)queryMessageWithMessageType:(iTetQueryMessageType)messageType
{
	return [[[self alloc] initWithMessageType:messageType] autorelease];
}

- (id)initWithMessageType:(iTetQueryMessageType)messageType
{
	type = messageType;
	contents = [[NSMutableDictionary alloc] init];
	
	return self;
}

#pragma mark -
#pragma mark Incoming Message Constructor

+ (id)queryMessageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	// Convert the data to a string
	NSString* messageContents = [NSString stringWithMessageData:messageData];
	
	// Special case: query-response list terminator has no contents
	if ([messageContents isEqualToString:iTetQueryResponseTerminatorMessageFormat])
	{
		type = queryResponseTerminatorMessage;
		return self;
	}
	
	// Split into space-separated components, stripping quotation marks but preserving quoted ranges as single components
	NSArray* messageTokens = [messageContents quotedComponentsSeparatedByString:@" "
																	stripQuotes:YES];
	if (messageTokens == nil)
	{
		NSLog(@"WARNING: unbalanced quotes in query-reply message: %@", messageContents);
		[self release];
		return nil;
	}
	
	contents = [[NSMutableDictionary alloc] initWithCapacity:[messageTokens count]];
	NSNumberFormatter* decFormat = [[NSNumberFormatter alloc] init];
	[decFormat setNumberStyle:NSNumberFormatterDecimalStyle];
	
	// Determine message type by the number of tokens in the message
	// Six tokens: attempt to parse as channel-list entry
	if ([messageTokens count] == 6)
	{
		type = channelListEntryMessage;
		[contents setObject:[messageTokens objectAtIndex:0]
					 forKey:iTetMessageChannelNameKey];
		[contents setObject:[messageTokens objectAtIndex:1]
					 forKey:iTetQueryMessageChannelDescriptionKey];
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:2]]
					 forKey:iTetQueryMessageChannelPlayerCountKey];
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:3]]
					 forKey:iTetQueryMessageChannelMaxPlayersKey];
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:4]]
					 forKey:iTetQueryMessageChannelPriorityKey];
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:5]]
					 forKey:iTetQueryMessageGameplayStateKey];
	}
	// Seven tokens: attempt to parse as player-list entry
	else if ([messageTokens count] == 7)
	{
		type = playerListEntryMessage;
		[contents setObject:[messageTokens objectAtIndex:0]
					 forKey:iTetMessagePlayerNicknameKey];
		[contents setObject:[messageTokens objectAtIndex:1]
					 forKey:iTetMessagePlayerTeamNameKey];
		[contents setObject:[messageTokens objectAtIndex:2]
					 forKey:iTetMessageClientVersionKey];
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:3]]
					 forKey:iTetMessagePlayerNumberKey];
		[contents setBool:([[messageTokens objectAtIndex:4] integerValue] == 1)
				   forKey:iTetQueryMessageGameplayStateKey];
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:5]]
					 forKey:iTetQueryMessagePlayerAuthLevelKey];
		[contents setObject:[messageTokens objectAtIndex:6]
					 forKey:iTetMessageChannelNameKey];
	}
	// Invalid number of tokens
	else
	{
		NSLog(@"WARNING: invalid number of tokens in query-reply message: %@", messageContents);
		[self release];
		return nil;
	}
	
	return self;
}

#pragma mark -
#pragma mark Accessors

- (NSData*)rawMessageData
{
	switch ([self type])
	{
		case channelListQueryMessage:
			return [iTetChannelListQueryMessageFormat messageData];
			
		case playerListQueryMessage:
			return [iTetPlayerListQueryMessageFormat messageData];
			
		default:
			NSLog(@"WARNING: rawMessageData called for invalid query message type: %d", [self type]);
			break;
	}
	
	return nil;
}

@synthesize type, contents;

@end
