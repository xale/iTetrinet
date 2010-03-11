//
//  iTetMessage+ClassFactory.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/10/10.
//

#import "iTetMessage+ClassFactory.h"
#import "iTetIncomingMessages.h"
#import "NSData+Searching.h"
#import "NSString+ASCIIData.h"

@implementation iTetMessage (ClassFactory)

+ (iTetMessage<iTetIncomingMessage>*)messageFromData:(NSData*)messageData
{
	// FIXME: debug logging
	NSMutableString* debugString = [NSMutableString string];
	char byte;
	for (NSUInteger i = 0; i < [messageData length]; i++)
	{
		byte = ((char*)[messageData bytes])[i];
		if (byte > 31)
			[debugString appendFormat:@"%c", byte];
		else
			[debugString appendFormat:@"<\\%02d>", byte];
	}
	NSLog(@"DEBUG:   received incoming message: %@", debugString);
	
	// Convert the first space-delimited word of the message to a string, and treat the rest as the contents
	NSString* messageDesignation;
	NSData* messageContents;
	
	// Search for the first space in the message data
	NSInteger firstSpace = [messageData indexOfByte:(uint8_t)' '];
	
	// If the message contains no spaces, treat it as a one-word message with no contents
	if (firstSpace == NSNotFound)
	{
		messageDesignation = [NSString stringWithASCIIData:messageData];
		messageContents = [NSData data];
	}
	else
	{
		messageDesignation = [NSString stringWithASCIIData:[messageData subdataToIndex:firstSpace]];
		messageContents = [messageData subdataFromIndex:(firstSpace + 1)];
	}
	
	// If the message is blank, it is just a server heartbeat
	if ([messageDesignation length] == 0)
		return [iTetHeartbeatMessage message];
	
	// If the message is not blank, determine which type of message it is
	NSNumber* type = [[self messageDesignations] objectForKey:messageDesignation];
	if (type == nil)
		type = [NSNumber numberWithInt:invalidMessage];
	
	switch ([type intValue])
	{
		case noConnectingMessage:
			return [iTetNoConnectingMessage messageFromData:messageContents];
			
		case playerNumberMessage:
			return [iTetPlayerNumberMessage messageFromData:messageContents];
		case playerJoinMessage:
			return [iTetPlayerJoinMessage messageFromData:messageContents];
		case playerLeaveMessage:
			return [iTetPlayerLeaveMessage messageFromData:messageContents];
		case playerTeamMessage:
			return [iTetPlayerTeamMessage messageFromData:messageContents];
		case winlistMessage:
			return [iTetWinlistMessage messageFromData:messageContents];
			
		case plineChatMessage:
			return [iTetPlineChatMessage messageFromData:messageContents];
		case plineActionMessage:
			return [iTetPlineActionMessage messageFromData:messageContents];
		case gameChatMessage:
			return [iTetGameChatMessage messageFromData:messageContents];
			
		case newGameMessage:
			return [iTetNewGameMessage messageFromData:messageContents];
		case inGameMessage:
			return [iTetInGameMessage messageFromData:messageContents];
		case pauseResumeGameMessage:
			return [iTetPauseResumeGameMessage messageFromData:messageContents];
		case endGameMessage:
			return [iTetEndGameMessage messageFromData:messageContents];
			
		case fieldstringMessage:
			return [iTetFieldstringMessage messageFromData:messageContents];
		case levelUpdateMessage:
		{
			// Special case: "lvl 0 *" is a client info request
			NSString* contents = [NSString stringWithASCIIData:messageContents];
			if ([[contents substringToIndex:1] integerValue] == 0)
				return [iTetClientInfoRequestMessage messageFromData:messageContents];
			
			return [iTetLevelUpdateMessage messageFromData:messageContents];
		}
		case specialMessage:
			return [iTetSpecialMessage messageFromData:messageContents];
		case playerLostMessage:
			return [iTetPlayerLostMessage messageFromData:messageContents];
		case playerWonMessage:
			return [iTetPlayerWonMessage messageFromData:messageContents];
			
		default:
			break;
	}
	
	// Unknown message type
	NSLog(@"WARNING: unknown message type received: '%@'", messageDesignation);
	
	return nil;
}

@end
