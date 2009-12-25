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
	int playerNumber;
	NSString* teamName;
	
	iTetField* field;
	int level;
}

- (id)initWithNickname:(NSString*)nick
		    number:(int)number
		  teamName:(NSString*)team;
- (id)initWithNickname:(NSString*)nick
		    number:(int)number;
- (id)initWithNumber:(int)number;

@property (readwrite, copy) NSString* nickname;
@property (readwrite, assign) int playerNumber;
@property (readwrite, copy) NSString* teamName;
@property (readwrite, retain) iTetField* field;
@property (readwrite, assign) int level;

@end
