//
//  iTetModel.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetModel.h"

#import "iTetNetworkContext.h"

#import "iTetOnlineGameContext.h"
#import "iTetOfflineGameContext.h"

@implementation iTetModel

- (void)dealloc
{
	// Disconnect from the network, if necessary
	[self closeCurrentConnection];
	
	// End offline game, if necessary
	[self endGame];
	
	[networkConnection release];
	[gameContext release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Network Connections

- (void)openConnectionToServer:(iTetServerInfo*)server
{
	// FIXME: WRITEME
}

- (void)closeCurrentConnection
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Game State

- (void)startGame
{
	// FIXME: WRITEME
}

- (void)endGame
{
	// FIXME: WRITEME
}

- (void)forfeitGame
{
	// FIXME: WRITEME
}

- (void)pauseGame
{
	// FIXME: WRITEME
}

- (void)resumeGame
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Accessors

@synthesize networkConnection;

- (BOOL)connectionOpen
{
	return [[self networkConnection] connectionOpen];
}

@synthesize gameContext;

- (BOOL)gameInProgress
{
	return [[self gameContext] gameInProgress];
}

- (BOOL)gamePaused
{
	return [[[self gameContext] game] isPaused];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
	// Retrieve the default set of triggering key paths
	NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	// Add subpaths for the encapsulated accessors
	if ([key isEqualToString:@"connectionOpen"])
		keyPaths = [keyPaths setByAddingObject:@"networkManager.connectionOpen"];
	else if ([key isEqualToString:@"gameInProgress"])
		keyPaths = [keyPaths setByAddingObject:@"gameContext.gameInProgress"];
	else if ([key isEqualToString:@"gamePaused"])
		keyPaths = [keyPaths setByAddingObject:@"gameContext.game.isPaused"];
	
	return keyPaths;
}

@end
