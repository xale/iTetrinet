//
//  iTetMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/2/10.
//

#import <Cocoa/Cocoa.h>

#define NUM_MESSAGE_TYPES	

typedef enum
{
	playerNumberMessage,
	playerJoinMessage,
	playerLeaveMessage,
	playerTeamMessage,
	winlistMessage,
	plineChatMessage,
	plineActionMessage,
	gameChatMessage,
	newGameMessage,
	inGameMessage,
	fieldstringMessage,
	levelUpdateMessage,
	specialUsedMessage,
	classicAddMessage,
	playerLostMessage,
	playerWonMessage,
	pauseGameMessage,
	endGameMessage,
	noConnectingMessage,
	heartbeatMessage
} iTetMessageType;

@interface iTetMessage : NSObject
{
	iTetMessageType messageType;
}

+ (id)messageFromData:(NSData*)data; 

- (id)messageFromData:(NSData*)data;

- (NSData*)rawMessageData;

@property (readonly) iTetMessageType messageType;

@end
