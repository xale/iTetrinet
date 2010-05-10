//
//  iTetServerPlayer.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//

#import "iTetServerPlayer.h"

#define iTetServerPlayerName	NSLocalizedStringFromTable(@"SERVER", @"Players", @"The placeholder name for messages sent by the server, (as opposed to one of the players) used in the chat views and game actions list")

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
