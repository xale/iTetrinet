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
		  teamName:(NSString*)team
{
	nickname = [nick copy];
	playerNumber = number;
	teamName = [team copy];
	
	field = [[iTetField alloc] initWithRandomContents];
	
	return self;
}

- (id)initWithNickname:(NSString*)nick
		    number:(int)number
{
	return [self initWithNickname:nick
				     number:number
				   teamName:@""];
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
	[field release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize nickname;
@synthesize playerNumber;
@synthesize teamName;
@synthesize field;
@synthesize level;

@end
