//
//  iTetMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/2/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

#define ITET_NUM_MESSAGE_TYPES	(23)

typedef enum
{
	loginMessage,
	noConnectingMessage,
	clientInfoRequestMessage,
	clientInfoReplyMessage,
	heartbeatMessage,
	
	playerNumberMessage,
	playerJoinMessage,
	playerLeaveMessage,
	playerTeamMessage,
	winlistMessage,
	
	plineChatMessage,
	plineActionMessage,
	gameChatMessage,
	
	channelListQueryMessage,
	channelListEntryMessage,
	playerListQueryMessage,
	playerListEntryMessage,
	queryResponseTerminatorMessage,
	
	startStopGameMessage,
	newGameMessage,
	inGameMessage,
	pauseResumeGameMessage,
	endGameMessage,
	
	fieldstringMessage,
	levelUpdateMessage,
	specialMessage,
	playerLostMessage,
	playerWonMessage,
	
	invalidMessage
} iTetMessageType;

@interface iTetMessage : NSObject
{
	iTetMessageType messageType;
}

+ (NSDictionary*)messageDesignations;

@property (readonly) iTetMessageType messageType;

@end

@protocol iTetIncomingMessage

// Constructs a message from the raw data off-the-wire, minus the message token and the first space
+ (id)messageWithMessageData:(NSData*)messageData;
- (id)initWithMessageData:(NSData*)messageData;

@end

@protocol iTetOutgoingMessage

// Converts the message into raw data suitable for sending over-the-wire
- (NSData*)rawMessageData;

@end
