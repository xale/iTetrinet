//
//  iTetMessage+ClassFactory.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/10/10.
//

#import "iTetMessage+ClassFactory.h"
#import "iTetIncomingMessages.h"
#import "NSString+MessageData.h"
#import "NSData+SingleByte.h"
#import "NSData+Subdata.h"

@implementation iTetMessage (ClassFactory)

+ (iTetMessage<iTetIncomingMessage>*)messageFromData:(NSData*)messageData
{
	// Convert the first space-delimited word of the message to a string, and treat the rest as the contents
	NSString* messageDesignation;
	NSData* messageContents;
	
	// Search for the first space in the message data
	NSInteger firstSpace = [messageData indexOfByte:(uint8_t)' '];
	
	// If the message contains no spaces, treat it as a one-word message with no contents
	if (firstSpace == NSNotFound)
	{
		messageDesignation = [NSString stringWithMessageData:messageData];
		messageContents = [NSData data];
	}
	else
	{
		messageDesignation = [NSString stringWithMessageData:[messageData subdataToIndex:firstSpace]];
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
			return [iTetNoConnectingMessage messageWithMessageData:messageContents];
			
		case playerNumberMessage:
			return [iTetPlayerNumberMessage messageWithMessageData:messageContents];
		case playerJoinMessage:
			return [iTetPlayerJoinMessage messageWithMessageData:messageContents];
		case playerLeaveMessage:
			return [iTetPlayerLeaveMessage messageWithMessageData:messageContents];
		case playerTeamMessage:
			return [iTetPlayerTeamMessage messageWithMessageData:messageContents];
		case winlistMessage:
			return [iTetWinlistMessage messageWithMessageData:messageContents];
			
		case plineChatMessage:
			return [iTetPlineChatMessage messageWithMessageData:messageContents];
		case plineActionMessage:
			return [iTetPlineActionMessage messageWithMessageData:messageContents];
		case gameChatMessage:
			return [iTetGameChatMessage messageWithMessageData:messageContents];
			
		case newGameMessage:
			return [iTetNewGameMessage messageWithMessageData:messageContents];
		case inGameMessage:
			return [iTetInGameMessage messageWithMessageData:messageContents];
		case pauseResumeGameMessage:
			return [iTetPauseResumeGameMessage messageWithMessageData:messageContents];
		case endGameMessage:
			return [iTetEndGameMessage messageWithMessageData:messageContents];
			
		case fieldstringMessage:
			return [iTetFieldstringMessage messageWithMessageData:messageContents];
		case levelUpdateMessage:
		{
			// Special case: "lvl 0 *" is a client info request
			NSString* contents = [NSString stringWithMessageData:messageContents];
			if ([[contents substringToIndex:1] integerValue] == 0)
				return [iTetClientInfoRequestMessage messageWithMessageData:messageContents];
			
			return [iTetLevelUpdateMessage messageWithMessageData:messageContents];
		}
		case specialMessage:
			return [iTetSpecialMessage messageWithMessageData:messageContents];
		case playerLostMessage:
			return [iTetPlayerLostMessage messageWithMessageData:messageContents];
		case playerWonMessage:
			return [iTetPlayerWonMessage messageWithMessageData:messageContents];
			
		default:
			break;
	}
	
	// Unknown message type
	NSLog(@"WARNING: unknown message type received: '%@'", messageDesignation);
	
	return nil;
}

@end
