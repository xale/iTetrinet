//
//  iTetMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/2/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

#import "iTetPlayer.h"
#import "iTetField.h"
#import "NSNumber+iTetSpecials.h"
#import "iTetServerInfo.h"

#import "NSAttributedString+TetrinetTextAttributes.h"

#import "NSDictionary+AdditionalTypes.h"
#import "NSString+MessageData.h"

#pragma mark Message Formats

NSDictionary* iTetMessageFormats = nil;
NSString* const iTetTetrinetLoginMessageFormat =			@"tetrisstart %@ %@";	// TetriNET protocol
NSString* const iTetTetrifastLoginMessageFormat =			@"tetrifaster %@ %@";	// Tetrifast protocol
NSString* const iTetNoConnectingMessageFormat =				@"noconnecting %@";
NSString* const iTetClientInfoRequestMessageFormat =		@"lvl 0 0";
NSString* const iTetClientInfoReplyMessageFormat =			@"clientinfo %@ %@";
// Heartbeat message has no format string

NSString* const iTetTetrinetPlayerNumberMessageFormat =		@"playernum %d";		// TetriNET protocol
NSString* const iTetTetrifastPlayerNumberMessageFormat =	@")#)(!@(*3 %d";		// Tetrifast protocol
NSString* const iTetPlayerJoinMessageFormat =				@"playerjoin %d %@";
NSString* const iTetPlayerLeaveMessageFormat =				@"playerleave %d";
NSString* const iTetPlayerTeamMessageFormat =				@"team %d %@";
NSString* const iTetWinlistMessageFormat =					@"winlist %@";

NSString* const iTetPLineChatMessageFormat =				@"pline %d %@";
NSString* const iTetPLineActionMessageFormat =				@"plineact %d %@";
NSString* const iTetGameChatMessageFormat =					@"gmsg %@";
NSString* const iTetJoinChannelMessageFormat =				@"pline %d /join #%@";

NSString* const iTetStartStopGameMessageFormat =			@"startgame %d %d";
NSString* const iTetTetrinetNewGameMessageFormat =			@"newgame %@";			// TetriNET protocol
NSString* const iTetTetrifastNewGameMessageFormat =			@"******* %@";			// Tetrifast protocol
NSString* const iTetInGameMessageFormat =					@"ingame";
NSString* const iTetPauseResumeGameMessageFormat =			@"pause %d %d";
NSString* const iTetEndGameMessageFormat =					@"endgame";

NSString* const iTetFieldstringMessageFormat =				@"f %d %@";
NSString* const iTetLevelUpdateMessageFormat =				@"lvl %d %d";
NSString* const iTetSpecialUsedMessageFormat =				@"sb %d %@ %d";
NSString* const iTetPlayerLostMessageFormat =				@"playerlost %d";
NSString* const iTetPlayerWonMessageFormat =				@"playerwon %d";

#pragma mark -
#pragma mark Message Contents Keys

NSString* const iTetMessageServerAddressKey =			@"iTetServerAddress";
NSString* const iTetMessageGameVersionKey =				@"iTetGameVersion";
NSString* const iTetMessageNoConnectingReasonKey =		@"iTetNoConnectingReason";
NSString* const iTetMessageClientNameKey =				@"iTetClientName";
NSString* const iTetMessageClientVersionKey =			@"iTetClientVersion";

NSString* const iTetMessagePlayerNumberKey =			@"iTetPlayerNumber";
NSString* const iTetMessageTargetPlayerNumberKey =		@"iTetTargetPlayerNumber";

NSString* const iTetMessagePlayerNicknameKey =			@"iTetPlayerNickname";
NSString* const iTetMessagePlayerTeamNameKey =			@"iTetPlayerTeamName";
NSString* const iTetMessageWinlistArrayKey =			@"iTetWinlistArray";

NSString* const iTetMessageChatContentsKey =			@"iTetChatContents";
NSString* const iTetMessageChannelNameKey =				@"iTetChannelName";

NSString* const iTetMessageStartStopRequestTypeKey =	@"iTetStartStopRequestType";
NSString* const iTetMessageGameRulesArrayKey =			@"iTetGameRulesArray";
NSString* const iTetMessagePauseResumeRequestTypeKey =	@"iTetPauseResumeState";

NSString* const iTetMessageFieldstringKey =				@"iTetFieldstring";
NSString* const iTetMessageLevelNumberKey =				@"iTetLevelNumber";
NSString* const iTetMessageSpecialKey =					@"iTetSpecial";

BOOL iTetMessageTypeHasPlayerNumberFirst(iTetMessageType t)
{
	return ((t == tetrinetPlayerNumberMessage) || (t == tetrifastPlayerNumberMessage) || (t == playerJoinMessage) || (t == playerLeaveMessage) ||
			(t == playerTeamMessage) || (t == plineChatMessage) || (t == plineActionMessage) || (t == fieldstringMessage) ||
			(t == levelUpdateMessage) || (t == playerLostMessage) || (t == playerWonMessage));
}

#pragma mark -

@interface iTetMessage (Private)

- (NSData*)rawLoginMessageData;
+ (NSDictionary*)messageDesignations;

@end

#pragma mark -

@implementation iTetMessage

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

+ (id)messageWithMessageType:(iTetMessageType)messageType
{
	return [[[self alloc] initWithMessageType:messageType] autorelease];
}

- (id)initWithMessageType:(iTetMessageType)messageType
{
	type = messageType;
	contents = [[NSMutableDictionary alloc] init];
	
	return self;
}

#pragma mark -
#pragma mark Incoming Message Constructor

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	// Attempt to determine the type of the message
	
	// Special case: if the message is blank, this is just a server heartbeat
	if ([messageData length] == 0)
	{
		type = heartbeatMessage;
		goto done;
	}
	
	// Convert the message to a string, split on spaces
	NSArray* messageContents = [[NSString stringWithMessageData:messageData] componentsSeparatedByString:@" "];
	
	// Treat the first space-separated token as the message "designation", i.e., identifying the message type
	NSString* messageDesignation = [messageContents objectAtIndex:0];
	
	// Attempt to determine the type of message using the designation
	NSNumber* typeSearchResult = [[iTetMessage messageDesignations] objectForKey:messageDesignation];
	if (typeSearchResult == nil)
	{
		NSAssert1(NO, @"unknown message designation: %@", messageDesignation);
		[self release];
		return nil;
	}
	type = (iTetMessageType)[typeSearchResult intValue];
	contents = [[NSMutableDictionary alloc] init];
	
	// Create a decimal number formatter
	NSNumberFormatter* decFormat = [[[NSNumberFormatter alloc] init] autorelease];
	[decFormat setNumberStyle:NSNumberFormatterDecimalStyle];
	
	// Read the message's contents
	
	// "No Connecting" reason message
	if (type == noConnectingMessage)
	{
		if ([messageContents count] >= 3)
		{
			[contents setObject:[[messageContents subarrayWithRange:NSMakeRange(1, ([messageContents count] - 1))] componentsJoinedByString:@" "]
						 forKey:iTetMessageNoConnectingReasonKey];
		}
		else
		{
			[contents setObject:[NSString string]
						 forKey:iTetMessageNoConnectingReasonKey];
		}
	}
	
	// Player number of sender or relevant player
	if (iTetMessageTypeHasPlayerNumberFirst(type))
	{
		[contents setObject:[decFormat numberFromString:[messageContents objectAtIndex:1]]
					 forKey:iTetMessagePlayerNumberKey];
	}
	else if (type == specialUsedMessage)
	{
		[contents setObject:[decFormat numberFromString:[messageContents objectAtIndex:3]] 
					 forKey:iTetMessagePlayerNumberKey];
	}
	
	// Player number of target player ("special used" messages)
	if (type == specialUsedMessage)
	{
		[contents setObject:[decFormat numberFromString:[messageContents objectAtIndex:1]]
					 forKey:iTetMessageTargetPlayerNumberKey];
	}
	
	// Player's nickname ("player join" messages)
	if (type == playerJoinMessage)
	{
		[contents setObject:[messageContents objectAtIndex:2]
					 forKey:iTetMessagePlayerNicknameKey];
	}
	
	// Player's team name ("player team" messages)
	if (type == playerTeamMessage)
	{
		if ([messageContents count] >= 3)
		{	
			[contents setObject:[messageContents objectAtIndex:2]
						 forKey:iTetMessagePlayerTeamNameKey];
		}
		else
		{
			[contents setObject:[NSString string]
						 forKey:iTetMessagePlayerTeamNameKey];
		}
	}
	
	// Winlist array (winlist messages)
	if (type == winlistMessage)
	{
		if ([messageContents count] >= 3)
		{
			[contents setObject:[messageContents subarrayWithRange:NSMakeRange(1, ([messageContents count] - 1))]
						 forKey:iTetMessageWinlistArrayKey];
		}
		else
		{
			[contents setObject:[NSArray array]
						 forKey:iTetMessageWinlistArrayKey];
		}
	}
	
	// Chat message contents (pline chat, pline action, and game chat messages)
	if ((type == plineChatMessage) || (type == plineActionMessage))
	{
		NSString* chatContents = [[messageContents subarrayWithRange:NSMakeRange(2, ([messageContents count] - 2))] componentsJoinedByString:@" "];
		[contents setObject:[NSAttributedString attributedStringWithPlineMessageContents:chatContents]
					 forKey:iTetMessageChatContentsKey];
	}
	else if (type == gameChatMessage)
	{
		[contents setObject:[[messageContents subarrayWithRange:NSMakeRange(1, ([messageContents count] - 1))] componentsJoinedByString:@" "]
					 forKey:iTetMessageChatContentsKey];
	}
	
	// Game rules array ("new game" messages)
	if ((type == tetrinetNewGameMessage) || (type == tetrifastNewGameMessage))
	{
		[contents setObject:[messageContents subarrayWithRange:NSMakeRange(1, ([messageContents count] - 1))]
					 forKey:iTetMessageGameRulesArrayKey];
	}
	
	// Paused/resumed game state ("pause/resume" messages)
	if (type == pauseResumeGameMessage)
	{
		[contents setObject:[decFormat numberFromString:[messageContents objectAtIndex:1]]
					 forKey:iTetMessagePauseResumeRequestTypeKey];
	}
	
	// Fieldstring (fieldstring messages)
	if (type == fieldstringMessage)
	{
		if ([messageContents count] >= 3)
		{
			[contents setObject:[messageContents objectAtIndex:2]
						 forKey:iTetMessageFieldstringKey];
		}
		else
		{
			[contents setObject:[NSString string]
						 forKey:iTetMessageFieldstringKey];
		}
	}
	
	// Level number ("level update" messages)
	if (type == levelUpdateMessage)
	{
		[contents setObject:[decFormat numberFromString:[messageContents objectAtIndex:2]]
					 forKey:iTetMessageLevelNumberKey];
		
		// Special case: if the player and level numbers are both zero, this is a client info request
		if (([contents integerForKey:iTetMessagePlayerNumberKey] == 0) && ([contents integerForKey:iTetMessageLevelNumberKey] == 0))
		{
			type = clientInfoRequestMessage;
			[contents release];
			contents = nil;
			goto done;
		}
	}
	
	// Special type ("special used" messages)
	if (type == specialUsedMessage)
	{
		[contents setObject:[NSNumber numberWithSpecialFromMessageName:[messageContents objectAtIndex:2]]
					 forKey:iTetMessageSpecialKey];
	}
	
done:
	return self;
}

#pragma mark -
#pragma mark Outgoing Message Data

- (NSData*)rawMessageData
{
	// Most messages require a player number
	NSInteger playerNumber = [[self contents] integerForKey:iTetMessagePlayerNumberKey];
	
	// Create a string containing the message contents in the appropriate format for the type
	NSString* messageContents = nil;
	switch (type)
	{
		case heartbeatMessage:
			// Special case: heartbeat message has no contents
			return [NSData data];
			
		case tetrinetLoginMessage:
		case tetrifastLoginMessage:
			// Special case: login messages have to be "encrypted" before sending
			return [self rawLoginMessageData];
			
		case playerTeamMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSString* teamName = [[self contents] objectForKey:iTetMessagePlayerTeamNameKey];
			NSParameterAssert(teamName != nil);
			
			messageContents = [NSString stringWithFormat:iTetPlayerTeamMessageFormat, playerNumber, teamName];
			break;
		}	
		case clientInfoReplyMessage:
		{
			NSString* clientName = [[self contents] objectForKey:iTetMessageClientNameKey];
			NSParameterAssert(clientName != nil);
			NSString* clientVersion = [[self contents] objectForKey:iTetMessageClientVersionKey];
			NSParameterAssert(clientVersion != nil);
			
			messageContents = [NSString stringWithFormat:iTetClientInfoReplyMessageFormat, clientName, clientVersion];
			break;
		}	
		case plineChatMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSString* chatContents = [[[self contents] objectForKey:iTetMessageChatContentsKey] plineMessageString];
			NSParameterAssert(chatContents != nil);
			
			messageContents = [NSString stringWithFormat:iTetPLineChatMessageFormat, playerNumber, chatContents];
			break;
		}	
		case plineActionMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSString* chatContents = [[[self contents] objectForKey:iTetMessageChatContentsKey] plineMessageString];
			NSParameterAssert(chatContents != nil);
			
			messageContents = [NSString stringWithFormat:iTetPLineActionMessageFormat, playerNumber, chatContents];
			break;
		}
		case gameChatMessage:
		{
			NSString* chatContents = [[self contents] objectForKey:iTetMessageChatContentsKey];
			NSParameterAssert(chatContents != nil);
			
			messageContents = [NSString stringWithFormat:iTetGameChatMessageFormat, chatContents];
			break;
		}	
		case joinChannelMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSString* channelName = [[self contents] objectForKey:iTetMessageChannelNameKey];
			NSParameterAssert(channelName != nil);
			
			messageContents = [NSString stringWithFormat:iTetJoinChannelMessageFormat, playerNumber, channelName];
			break;
		}	
		case startStopGameMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSNumber* startStopRequestType = [[self contents] objectForKey:iTetMessageStartStopRequestTypeKey];
			NSParameterAssert(startStopRequestType != nil);
			
			messageContents = [NSString stringWithFormat:iTetStartStopGameMessageFormat, [startStopRequestType intValue], playerNumber];
			break;
		}	
		case pauseResumeGameMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSNumber* pauseResumeRequestType = [[self contents] objectForKey:iTetMessagePauseResumeRequestTypeKey];
			NSParameterAssert(pauseResumeRequestType != nil);
			
			messageContents = [NSString stringWithFormat:iTetPauseResumeGameMessageFormat, [pauseResumeRequestType intValue], playerNumber];
			break;
		}	
		case fieldstringMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSString* fieldstring = [[self contents] objectForKey:iTetMessageFieldstringKey];
			NSParameterAssert(fieldstring != nil);
			
			messageContents = [NSString stringWithFormat:iTetFieldstringMessageFormat, playerNumber, fieldstring];
			
			break;
		}	
		case levelUpdateMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSNumber* levelNumber = [[self contents] objectForKey:iTetMessageLevelNumberKey];
			NSParameterAssert(levelNumber != nil);
			
			messageContents = [NSString stringWithFormat:iTetLevelUpdateMessageFormat, playerNumber, [levelNumber integerValue]];
			break;
		}	
		case specialUsedMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			NSNumber* targetPlayerNumber = [[self contents] objectForKey:iTetMessageTargetPlayerNumberKey];
			NSParameterAssert(targetPlayerNumber != nil);	// Not using "checkPlayerNumber" macro, since target may be '0' (all players)
			NSNumber* special = [[self contents] objectForKey:iTetMessageSpecialKey];
			NSParameterAssert(special != nil);
			
			messageContents = [NSString stringWithFormat:iTetSpecialUsedMessageFormat, [targetPlayerNumber integerValue], [special specialMessageName], playerNumber];
			break;
		}	
		case playerLostMessage:
		{
			iTetCheckPlayerNumber(playerNumber);
			
			messageContents = [NSString stringWithFormat:iTetPlayerLostMessageFormat, playerNumber];
			break;
		}	
		default:
		{
			NSAssert1(NO, @"rawMessageData called on message of invalid type: %d", [self type]);
			return nil;
		}
	}
	
	return [messageContents messageData];
}

- (NSData*)rawLoginMessageData
{
	// Sanity checks
	NSParameterAssert((([self type] == tetrinetLoginMessage) || ([self type] == tetrifastLoginMessage)));
	NSString* nickname = [[self contents] objectForKey:iTetMessagePlayerNicknameKey];
	NSParameterAssert(nickname != nil);
	NSNumber* version = [[self contents] objectForKey:iTetMessageGameVersionKey];
	NSParameterAssert((version != nil) && (([version intValue] == version113) || ([version intValue] == version114)));
	NSString* address = [[self contents] objectForKey:iTetMessageServerAddressKey];
	NSParameterAssert(address != nil);
	
	// Fill in the player's nickname and the protocol version number to the login message format
	NSString* format;
	if ([self type] == tetrinetLoginMessage)
		format = iTetTetrinetLoginMessageFormat;
	else
		format = iTetTetrifastLoginMessageFormat;
	NSString* versionString;
	if ([version intValue] == version113)
		versionString = iTet113GameVersionName;
	else
		versionString = iTet114GameVersionName;
	NSData* messageData = [[NSString stringWithFormat:format, nickname, versionString] messageData];
	
	// Split the server's IP address into integer components
	NSArray* ipComponents = [address componentsSeparatedByString:@"."];
	NSInteger ip[4];
	NSUInteger i;
	for (i = 0; i < 4; i++)
		ip[i] = [[ipComponents objectAtIndex:i] integerValue];
	
	// Create the "hash" of the IP address
	NSString* ipHash = [NSString stringWithFormat:@"%d", (54*ip[0]) + (41*ip[1]) + (29*ip[2]) + (17*ip[3])];
	
	// Create an "encoded" version of the message, starting with a random two-digit hexadecimal value in the range [0, 255)
	uint8_t x = random() % 255;
	NSMutableString* encodedMessage = [NSMutableString stringWithFormat:@"%02X", x];
	
	// Create a "hash" of each character in the message and append it as a hexadecimal value to the end of the encoded string
	const uint8_t* rawData = [messageData bytes];
	for (i = 0; i < [messageData length]; i++)
	{
		// Modular-add value of current character
		x = ((x + rawData[i]) % 255);
		
		// XOR with a character of the IP address hash
		x ^= [ipHash characterAtIndex:(i % [ipHash length])];
		
		// Append the hexadecimal value to the output string
		[encodedMessage appendFormat:@"%02X", x];
	}
	
	// Convert the encoded message to a data object before returning
	return [encodedMessage messageData];
}

#pragma mark -
#pragma mark Accessors

+ (NSDictionary*)messageDesignations
{
	@synchronized(self)
	{
		if (iTetMessageFormats == nil)
		{
			// Create a lookup-table of message format-strings to message types
			NSMutableDictionary* messages = [[NSMutableDictionary alloc] init];
			
			// Connection-handling messages
			[messages setInt:noConnectingMessage
					  forKey:[iTetNoConnectingMessageFormat messageDesignation]];
			[messages setInt:tetrinetPlayerNumberMessage
					  forKey:[iTetTetrinetPlayerNumberMessageFormat messageDesignation]];
			[messages setInt:tetrifastPlayerNumberMessage
					  forKey:[iTetTetrifastPlayerNumberMessageFormat messageDesignation]];
			
			// Player-status messages
			[messages setInt:playerJoinMessage
					  forKey:[iTetPlayerJoinMessageFormat messageDesignation]];
			[messages setInt:playerLeaveMessage
					  forKey:[iTetPlayerLeaveMessageFormat messageDesignation]];
			[messages setInt:playerTeamMessage
					  forKey:[iTetPlayerTeamMessageFormat messageDesignation]];
			[messages setInt:winlistMessage
					  forKey:[iTetWinlistMessageFormat messageDesignation]];
			
			// Chat messages
			[messages setInt:plineChatMessage
					  forKey:[iTetPLineChatMessageFormat messageDesignation]];
			[messages setInt:plineActionMessage
					  forKey:[iTetPLineActionMessageFormat messageDesignation]];
			[messages setInt:gameChatMessage
					  forKey:[iTetGameChatMessageFormat messageDesignation]];
			
			// Game-state messages
			[messages setInt:tetrinetNewGameMessage
					  forKey:[iTetTetrinetNewGameMessageFormat messageDesignation]];
			[messages setInt:tetrifastNewGameMessage
					  forKey:[iTetTetrifastNewGameMessageFormat messageDesignation]];
			[messages setInt:inGameMessage
					  forKey:[iTetInGameMessageFormat messageDesignation]];
			[messages setInt:pauseResumeGameMessage
					  forKey:[iTetPauseResumeGameMessageFormat messageDesignation]];
			[messages setInt:endGameMessage
					  forKey:[iTetEndGameMessageFormat messageDesignation]];
			
			// Gameplay messages
			[messages setInt:fieldstringMessage
					  forKey:[iTetFieldstringMessageFormat messageDesignation]];
			[messages setInt:levelUpdateMessage
					  forKey:[iTetLevelUpdateMessageFormat messageDesignation]];
			[messages setInt:specialUsedMessage
					  forKey:[iTetSpecialUsedMessageFormat messageDesignation]];
			[messages setInt:playerLostMessage
					  forKey:[iTetPlayerLostMessageFormat messageDesignation]];
			[messages setInt:playerWonMessage
					  forKey:[iTetPlayerWonMessageFormat messageDesignation]];
			
			iTetMessageFormats = [messages copy];
		}
	}
	
	return iTetMessageFormats;
}

@synthesize type, contents;

@end

