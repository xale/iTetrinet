//
//  iTetPlayer.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/17/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetField.h"

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

@property (readwrite, copy) NSString* nickname;
@property (readwrite, assign) NSInteger playerNumber;
@property (readwrite, copy) NSString* teamName;
@property (readwrite, assign, getter=isPlaying) BOOL playing;
@property (readwrite, retain) iTetField* field;
@property (readwrite, assign) NSInteger level;

@end
