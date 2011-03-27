//
//  iTetModel.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetNetworkContext;
@class iTetGameContext;
@class iTetServerInfo;

@interface iTetModel : NSObject
{
	iTetNetworkContext* networkConnection;
	iTetGameContext* gameContext;
}

- (void)openConnectionToServer:(iTetServerInfo*)server;
- (void)closeCurrentConnection;

- (void)startGame;
- (void)endGame;
- (void)forfeitGame;
- (void)pauseGame;
- (void)resumeGame;

@property (readonly) iTetNetworkContext* networkConnection;
@property (readonly) BOOL connectionOpen;

@property (readonly) iTetGameContext* gameContext;
@property (readonly) BOOL gameInProgress;
@property (readonly) BOOL gamePaused;

@end
