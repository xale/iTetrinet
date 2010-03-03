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

- (id)initWithMessageData:(NSData*)data;

@end

@protocol iTetOutgoingMessage

- (NSData*)rawMessageData;

@end
