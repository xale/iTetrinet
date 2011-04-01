//
//  iTetStartStopGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/1/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetStartStopGameMessage.h"

NSString* const iTetStartStopGameMessageTag =	@"startgame";

@implementation iTetStartStopGameMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat the second token as the start/stop state
	startState = [[tokens objectAtIndex:1] intValue];
	
	// Treat the third token as the sender player number
	senderPlayerNumber = [[tokens objectAtIndex:2] integerValue];
	
	return self;
}

+ (id)startGameMessageFromPlayer:(NSInteger)playerNumber
{
	return [[[self alloc] initWithPlayerNumber:playerNumber
									startState:startGame] autorelease];
}

+ (id)stopGameMessageFromPlayer:(NSInteger)playerNumber
{
	return [[[self alloc] initWithPlayerNumber:playerNumber
									startState:stopGame] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)playerNumber
				startState:(iTetStartStopState)state
{
	if (!(self = [super init]))
		return nil;
	
	senderPlayerNumber = playerNumber;
	startState = state;
	
	return self;
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %d %ld", iTetStartStopGameMessageTag, [self startState], (long)[self senderPlayerNumber]];
}

#pragma mark -
#pragma mark Accessors

@synthesize senderPlayerNumber;
@synthesize startState;

@end
