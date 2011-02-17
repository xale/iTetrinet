//
//  iTetPlayersController.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetPlayer;
@class iTetLocalPlayer;
@class iTetServerPlayer;

@class iTetMainWindowController;
@class iTetNetworkController;

@interface iTetPlayersController : NSObject <NSUserInterfaceValidations>
{
	IBOutlet iTetMainWindowController* windowController;
	IBOutlet iTetNetworkController* networkController;
	
	IBOutlet NSWindow* teamNameSheet;
	IBOutlet NSTextField* teamNameField;
	
	NSMutableArray* players;
	NSInteger playerCount;
	iTetLocalPlayer* localPlayer;
	iTetServerPlayer* serverPlayer;
	iTetPlayer* lastWinningPlayer;
}

- (IBAction)changeTeamName:(id)sender;
- (IBAction)closeTeamNameSheet:(id)sender;

- (void)createLocalPlayerWithNumber:(NSInteger)number
						   nickname:(NSString*)nickname
						   teamName:(NSString*)teamName;
- (void)changeLocalPlayerNumber:(NSInteger)number;
- (void)addPlayerWithNumber:(NSInteger)playerNumber
				   nickname:(NSString*)nick;
- (void)setTeamName:(NSString*)teamName
	forPlayerNumber:(NSInteger)playerNumber;
- (void)setLevel:(NSInteger)level
 forPlayerNumber:(NSInteger)playerNumber;
- (void)setGameStartedForAllRemotePlayers;
- (void)setGameLostForPlayerNumber:(NSInteger)playerNumber;
- (void)kickPlayerNumber:(NSInteger)playerNumber;
- (void)removePlayerNumber:(NSInteger)playerNumber;
- (void)removeAllPlayers;
- (iTetPlayer*)playerNumber:(NSInteger)playerNumber;

@property (readonly) NSArray* playerList;
@property (readonly) NSNumber* averagePlayerLevel;
@property (readwrite, retain) iTetLocalPlayer* localPlayer;
@property (readonly) iTetServerPlayer* serverPlayer;
@property (readwrite, retain) iTetPlayer* lastWinningPlayer;
@property (readonly) iTetPlayer* operatorPlayer;
@property (readonly) iTetPlayer* remotePlayer1;
@property (readonly) iTetPlayer* remotePlayer2;
@property (readonly) iTetPlayer* remotePlayer3;
@property (readonly) iTetPlayer* remotePlayer4;
@property (readonly) iTetPlayer* remotePlayer5;
- (iTetPlayer*)remotePlayerNumber:(NSInteger)n;

@end
