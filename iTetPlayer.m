//
//  iTetPlayer.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/17/09.
//

#import "iTetPlayer.h"

@implementation iTetPlayer

- (id)initWithNickname:(NSString*)nick
		    number:(int)number
{
	nickname = [nick copy];
	playerNumber = number;
	teamName = [[NSString alloc] init];
	
	board = [[iTetBoard alloc] initWithRandomContents];
	
	return self;
}

- (id)initWithNumber:(int)number
{
	return [self initWithNickname:@"Unnamed Player"
				     number:number];
}

- (void)dealloc
{
	[nickname release];
	[teamName release];
	[board release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize nickname;
@synthesize playerNumber;
@synthesize teamName;
@synthesize board;

@end
