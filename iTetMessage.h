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

typedef enum
{
	invalidMessage = 0,
	
	tetrinetLoginMessage,
	tetrifastLoginMessage,
	noConnectingMessage,
	clientInfoRequestMessage,
	clientInfoReplyMessage,
	heartbeatMessage,
	
	tetrinetPlayerNumberMessage,
	tetrifastPlayerNumberMessage,
	playerJoinMessage,
	playerLeaveMessage,
	playerTeamMessage,
	winlistMessage,
	
	plineChatMessage,
	plineActionMessage,
	gameChatMessage,
	joinChannelMessage,
	
	startStopGameMessage,
	tetrinetNewGameMessage,
	tetrifastNewGameMessage,
	inGameMessage,
	pauseResumeGameMessage,
	endGameMessage,
	
	fieldstringMessage,
	levelUpdateMessage,
	specialUsedMessage,
	playerLostMessage,
	playerWonMessage,
} iTetMessageType;

extern NSString* const iTetMessageServerAddressKey;
extern NSString* const iTetMessageGameVersionKey;
extern NSString* const iTetMessageNoConnectingReasonKey;
extern NSString* const iTetMessageClientNameKey;
extern NSString* const iTetMessageClientVersionKey;

extern NSString* const iTetMessagePlayerNumberKey;
extern NSString* const iTetMessageTargetPlayerNumberKey;

extern NSString* const iTetMessagePlayerNicknameKey;
extern NSString* const iTetMessagePlayerTeamNameKey;
extern NSString* const iTetMessageWinlistArrayKey;

extern NSString* const iTetMessageChatContentsKey;
extern NSString* const iTetMessageChannelNameKey;

extern NSString* const iTetMessageStartStopRequestTypeKey;
extern NSString* const iTetMessageGameRulesArrayKey;
extern NSString* const iTetMessagePauseResumeRequestTypeKey;

extern NSString* const iTetMessageFieldstringKey;
extern NSString* const iTetMessageLevelNumberKey;
extern NSString* const iTetMessageSpecialTypeKey;

@interface iTetMessage : NSObject
{
	iTetMessageType type;
	NSMutableDictionary* contents;
}

// Creates a message of the specified type
+ (id)messageWithMessageType:(iTetMessageType)messageType;
- (id)initWithMessageType:(iTetMessageType)messageType;

// Constructs a message from the raw data off-the-wire (excluding the terminator character)
+ (id)messageWithMessageData:(NSData*)messageData;
- (id)initWithMessageData:(NSData*)messageData;

// Converts the message into raw data suitable for sending over-the-wire
- (NSData*)rawMessageData;

@property (readonly) iTetMessageType type;
@property (readwrite, retain) NSMutableDictionary* contents;

@end
