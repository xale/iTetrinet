//
//  iTetQueryMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/26/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	invalidQueryMessage = 0,
	
	channelListQueryMessage,
	channelListEntryMessage,
	playerListQueryMessage,
	playerListEntryMessage,
	queryResponseTerminatorMessage
} iTetQueryMessageType;

extern NSString* const iTetQueryMessageChannelDescriptionKey;
extern NSString* const iTetQueryMessageChannelPlayerCountKey;
extern NSString* const iTetQueryMessageChannelMaxPlayersKey;
extern NSString* const iTetQueryMessageChannelPriorityKey;
extern NSString* const iTetQueryMessageGameplayStateKey;
extern NSString* const iTetQueryMessagePlayerAuthLevelKey;

@interface iTetQueryMessage : NSObject
{
	iTetQueryMessageType type;
	NSMutableDictionary* contents;
}

// Creates a message of the specified type
+ (id)queryMessageWithMessageType:(iTetQueryMessageType)messageType;
- (id)initWithMessageType:(iTetQueryMessageType)messagetype;

// Constructs a message from the raw data off-the-wire
+ (id)queryMessageWithMessageData:(NSData*)messageData;
- (id)initWithMessageData:(NSData*)messageData;

// Converts the message into raw data suitable for sending over-the-wire
- (NSData*)rawMessageData;

@property (readonly) iTetQueryMessageType type;
@property (readwrite, retain) NSMutableDictionary* contents;

@end
