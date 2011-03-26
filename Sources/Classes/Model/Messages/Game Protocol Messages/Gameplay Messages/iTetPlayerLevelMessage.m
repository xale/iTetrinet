//
//  iTetPlayerLevelMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerLevelMessage.h"
#import "iTetClientInfoRequestMessage.h"

NSString* const iTetPlayerLevelMessageTag =	@"lvl";

@implementation iTetPlayerLevelMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	// Read the player number and level from the second and third tokens
	playerNumber = [[tokens objectAtIndex:1] integerValue];
	playerLevel = [[tokens objectAtIndex:2] integerValue];
	
	// Check for the special-case client-info-request message
	if ((playerNumber == 0) && (playerLevel == 0))
	{
		// Release this object, and return another type of message instead
		[self release];
		return [[iTetClientInfoRequestMessage alloc] init];
	}
	
	return self;
}

+ (id)messageWithPlayerNumber:(NSInteger)playerNum
						level:(NSInteger)level
{
	return [[[self alloc] initWithPlayerNumber:playerNum
										 level:level] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)playerNum
					 level:(NSInteger)level
{
	playerNumber = playerNum;
	playerLevel = level;
	
	return self;
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %ld %ld", iTetPlayerLevelMessageTag, (long)[self playerNumber], (long)[self playerLevel]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize playerLevel;

@end
