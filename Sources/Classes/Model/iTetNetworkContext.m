//
//  iTetNetworkContext.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/17/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNetworkContext.h"

#import "iTetServerInfo.h"
#import "iTetOnlineGameContext.h"

@implementation iTetNetworkContext

- (id)initWithServer:(iTetServerInfo*)serverToConnect
		 gameContext:(iTetOnlineGameContext*)context
{
	server = [serverToConnect retain];
	gameContext = [context retain];
	
	return self;
}

- (void)dealloc
{
	// Disconnect, if necessary
	[self disconnect];
	
	[queryConnection release];
	[gameConnection release];
	
	[gameContext release];
	[server release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Connection Setup

- (BOOL)connect
{
	// FIXME: WRITEME
	return NO;
}

#pragma mark -
#pragma mark Connection Teardown

- (void)disconnect
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Accessors

@synthesize server;

- (BOOL)connectionOpen
{
	// FIXME: WRITEME
	return NO;
}

@end
