//
//  iTetPlayer.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/17/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetField.h"

#define ITET_MAX_PLAYERS	(6)
#define iTetCheckPlayerNumber(n) NSParameterAssert(((n) > 0) && ((n) <= ITET_MAX_PLAYERS))

@interface iTetPlayer : NSObject
{
	NSString* nickname;
	NSInteger playerNumber;
	NSString* teamName;
	
	BOOL playing;
	iTetField* field;
	NSInteger level;
}

+ (id)playerWithNickname:(NSString*)nick
				  number:(NSInteger)number
				teamName:(NSString*)team;
- (id)initWithNickname:(NSString*)nick
				number:(NSInteger)number
			  teamName:(NSString*)team;

+ (id)playerWithNickname:(NSString*)nick
				  number:(NSInteger)number;
- (id)initWithNickname:(NSString*)nick
				number:(NSInteger)number;

+ (id)playerWithNumber:(NSInteger)number;
- (id)initWithNumber:(NSInteger)number;

@property (readonly) BOOL isLocalPlayer;
@property (readonly) BOOL isServerPlayer;
@property (readwrite, copy) NSString* nickname;
@property (readwrite, assign) NSInteger playerNumber;
@property (readwrite, copy) NSString* teamName;
@property (readwrite, assign, getter=isPlaying) BOOL playing;
@property (readwrite, retain) iTetField* field;
@property (readwrite, assign) NSInteger level;

@end
