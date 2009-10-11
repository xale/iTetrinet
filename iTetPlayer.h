//
//  iTetPlayer.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/17/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetBoard.h"

@interface iTetPlayer : NSObject
{
	NSString* nickname;
	int playerNumber;
	NSString* teamName;
	
	iTetBoard* board;
}

- (id)initWithNickname:(NSString*)nick
		    number:(int)number;
- (id)initWithNumber:(int)number;

@property (readwrite, copy) NSString* nickname;
@property (readwrite, assign) int playerNumber;
@property (readwrite, copy) NSString* teamName;
@property (readwrite, retain) iTetBoard* board;

@end
