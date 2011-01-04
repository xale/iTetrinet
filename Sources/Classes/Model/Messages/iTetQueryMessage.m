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
	NSAssert1((messageTokens != nil), @"unbalanced quotes in query-reply message: %@", messageContents);
	
	contents = [[NSMutableDictionary alloc] initWithCapacity:[messageTokens count]];
	NSNumberFormatter* decFormat = [[[NSNumberFormatter alloc] init] autorelease];
	[decFormat setNumberStyle:NSNumberFormatterDecimalStyle];
	
	// Determine message type by the number of tokens in the message
	// Six tokens: attempt to parse as channel-list entry
	if ([messageTokens count] == 6)
	{
		type = channelListEntryMessage;
		
		// Channel name
		[contents setObject:[messageTokens objectAtIndex:0]
					 forKey:iTetMessageChannelNameKey];
		
		// Channel description (minus any HTML formatting)
		NSString* description = [NSString stringWithFormat:@"<p>%@</p>", [messageTokens objectAtIndex:1]];
		NSError* parseError = nil;
		NSXMLElement* html = [[[NSXMLElement alloc] initWithXMLString:description
																error:&parseError] autorelease];
		if (parseError != nil)
		{
			// If the description can't be parsed as HTML, treat it as unformatted text
			NSLog(@"warning: error parsing HTML formatting on description of channel '%@': %@", messageContents, parseError);
			description = [messageTokens objectAtIndex:1];
		}
		else
		{
			// Convert to a raw string, stripping HTML formatting
			description = [html stringValue];
		}
		[contents setObject:description
					 forKey:iTetQueryMessageChannelDescriptionKey];
		
		// Current/max player count
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:2]]
					 forKey:iTetQueryMessageChannelPlayerCountKey];
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:3]]
					 forKey:iTetQueryMessageChannelMaxPlayersKey];
		
		// Channel priority (order in which players join as channels fill)
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:4]]
					 forKey:iTetQueryMessageChannelPriorityKey];
		
		// Current gameplay state (in-game, paused, etc.)
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:5]]
					 forKey:iTetQueryMessageGameplayStateKey];
	}
	// Seven tokens: attempt to parse as player-list entry
	else if ([messageTokens count] == 7)
	{
		type = playerListEntryMessage;
		
		// Nickname
		[contents setObject:[messageTokens objectAtIndex:0]
					 forKey:iTetMessagePlayerNicknameKey];
		
		// Team name
		[contents setObject:[messageTokens objectAtIndex:1]
					 forKey:iTetMessagePlayerTeamNameKey];
		
		// Client protocol version
		[contents setObject:[messageTokens objectAtIndex:2]
					 forKey:iTetMessageClientVersionKey];
		
		// Player number
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:3]]
					 forKey:iTetMessagePlayerNumberKey];
		
		// Current gameplay state (playing or not)
		[contents setBool:([[messageTokens objectAtIndex:4] integerValue] == 1)
				   forKey:iTetQueryMessageGameplayStateKey];
		
		// Operator/administrator status
		[contents setObject:[decFormat numberFromString:[messageTokens objectAtIndex:5]]
					 forKey:iTetQueryMessagePlayerAuthLevelKey];
		
		// Channel name
		[contents setObject:[messageTokens objectAtIndex:6]
					 forKey:iTetMessageChannelNameKey];
	}
	// Invalid number of tokens
	else
	{
		NSString* excDesc = [NSString stringWithFormat:@"invalid number of tokens in query-reply message: %@", messageContents];
		NSException* unknownMessageException = [NSException exceptionWithName:@"iTetUnknownMessageTypeException"
																	   reason:excDesc
																	 userInfo:nil];
		@throw unknownMessageException;
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
		{
			NSString* excDesc = [NSString stringWithFormat:@"rawMessageData called for invalid query message type: %d", [self type]];
			NSException* invalidMessageTypeException = [NSException exceptionWithName:@"iTetInvalidMessageTypeException"
																			   reason:excDesc
																			 userInfo:nil];
			@throw invalidMessageTypeException;
		}
	}
	
	return nil;
}

@synthesize type, contents;

@end
