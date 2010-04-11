//
//  iTetChannelInfo.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/23/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetGameplayState.h"

@interface iTetChannelInfo : NSObject
{
	NSString* channelName;
	NSAttributedString* channelDescription;
	NSInteger currentPlayers;
	NSInteger maxPlayers;
	iTetGameplayState channelState;
}

+ (id)channelInfoWithName:(NSString*)name
			  description:(NSAttributedString*)desc
		   currentPlayers:(NSInteger)playerCount
			   maxPlayers:(NSInteger)max
					state:(iTetGameplayState)gameState;
- (id)initWithName:(NSString*)name
	   description:(NSAttributedString*)desc
	currentPlayers:(NSInteger)playerCount
		maxPlayers:(NSInteger)max
			 state:(iTetGameplayState)gameState;

@property (readonly) NSString* channelName;
@property (readonly) NSAttributedString* channelDescription;
@property (readonly) NSString* players;
@property (readonly) iTetGameplayState channelState;

@end
