//
//  iTetPlayersController.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/10.
//

#import <Cocoa/Cocoa.h>

@class iTetPlayer;
@class iTetLocalPlayer;
@class iTetServerPlayer;

#define ITET_MAX_PLAYERS	(6)

@interface iTetPlayersController : NSObject
{
	NSMutableArray* players;
	NSInteger playerCount;
	iTetLocalPlayer* localPlayer;
	iTetServerPlayer* serverPlayer;
}

- (void)setLocalPlayerNumber:(NSInteger)playerNumber
					nickname:(NSString*)nickname
					teamName:(NSString*)teamName;
- (void)addPlayerWithNumber:(NSInteger)playerNumber
				   nickname:(NSString*)nick;
- (void)setTeamName:(NSString*)teamName
	forPlayerNumber:(NSInteger)playerNumber;
- (void)setPlayerIsPlaying:(BOOL)playing
		   forPlayerNumber:(NSInteger)playerNumber;
- (void)setLevel:(NSInteger)level
 forPlayerNumber:(NSInteger)playerNumber;
- (void)setAllRemotePlayersToPlaying;
- (void)removePlayerNumber:(NSInteger)playerNumber;
- (void)removeAllPlayers;
- (iTetPlayer*)playerNumber:(NSInteger)playerNumber;
- (iTetPlayer*)operatorPlayer;

@property (readonly) NSArray* playerList;
@property (readonly) NSNumber* averagePlayerLevel;
@property (readwrite, retain) iTetLocalPlayer* localPlayer;
@property (readonly) iTetServerPlayer* serverPlayer;
@property (readonly) iTetPlayer* remotePlayer1;
@property (readonly) iTetPlayer* remotePlayer2;
@property (readonly) iTetPlayer* remotePlayer3;
@property (readonly) iTetPlayer* remotePlayer4;
@property (readonly) iTetPlayer* remotePlayer5;
- (iTetPlayer*)remotePlayerNumber:(NSInteger)n;

@end
