//
//  iTetPlayersController.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/10.
//

#import <Cocoa/Cocoa.h>

@class iTetPlayer;
@class iTetLocalPlayer;

#define ITET_MAX_PLAYERS	(6)

@interface iTetPlayersController : NSObject
{
	NSMutableArray* players;
	NSInteger playerCount;
	iTetLocalPlayer* localPlayer;
}

- (void)setLocalPlayerNumber:(NSInteger)number;
- (void)addPlayerWithNumber:(NSInteger)number
				   nickname:(NSString*)nick;
- (void)removePlayerNumber:(NSInteger)number;
- (void)removeAllPlayers;
- (iTetPlayer*)playerNumber:(NSInteger)number;
- (iTetPlayer*)operatorPlayer;
- (NSString*)playerNameForNumber:(NSInteger)number;

@property (readonly) NSArray* playerList;
@property (readonly) NSNumber* averagePlayerLevel;
@property (readwrite, retain) iTetLocalPlayer* localPlayer;
@property (readonly) iTetPlayer* remotePlayer1;
@property (readonly) iTetPlayer* remotePlayer2;
@property (readonly) iTetPlayer* remotePlayer3;
@property (readonly) iTetPlayer* remotePlayer4;
@property (readonly) iTetPlayer* remotePlayer5;
- (iTetPlayer*)remotePlayerNumber:(NSInteger)n;

@end
