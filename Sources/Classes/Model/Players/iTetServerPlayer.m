//
//  iTetServerPlayer.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetServerPlayer.h"

#define iTetServerPlayerName	NSLocalizedStringFromTable(@"nick.server", @"Players", @"The placeholder name used in the chat views for messages sent by the server (as opposed to one of the players) ")

@implementation iTetServerPlayer

- (id)init
{
	nickname = [[NSString alloc] initWithString:iTetServerPlayerName];
	playerNumber = 0;
	teamName = nil;
	playing = NO;
	field = nil;
	level = 0;
	
	return self;
}

- (id)initWithNickname:(NSString*)nick
				number:(NSInteger)number
			  teamName:(NSString*)team
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isServerPlayer
{
	return YES;
}

@end
