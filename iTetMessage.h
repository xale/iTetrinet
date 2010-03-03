//
//  iTetMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/2/10.
//

#import <Cocoa/Cocoa.h>

#define ITET_NUM_MESSAGE_TYPES	23

typedef enum
{
	loginMessage,
	clientInfoRequestMessage,
	clientInfoMessage,
	playerNumberMessage,
	playerJoinMessage,
	playerLeaveMessage,
	playerTeamMessage,
	winlistMessage,
	plineChatMessage,
	plineActionMessage,
	gameChatMessage,
	startStopGameMessage,
	newGameMessage,
	inGameMessage,
	fieldstringMessage,
	levelUpdateMessage,
	specialUsedMessage,
	classicAddMessage,
	playerLostMessage,
	playerWonMessage,
	pauseResumeGameMessage,
	endGameMessage,
	noConnectingMessage,
	heartbeatMessage
} iTetMessageType;

@interface iTetMessage : NSObject
{
	iTetMessageType messageType;
}

+ (iTetMessage*)messageFromData:(NSData*)data;

@property (readonly) iTetMessageType messageType;

@end

@protocol iTetIncomingMessage

// Constructs a message from the raw data off-the-wire, minus the message token and the first space
- (id)initWithMessageData:(NSData*)data;

@end

@protocol iTetOutgoingMessage

// Converts the message into raw data suitable for sending over-the-wire
- (NSData*)rawMessageData;

@end
