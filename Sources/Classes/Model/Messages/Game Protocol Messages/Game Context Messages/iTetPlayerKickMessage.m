//
//  iTetPlayerKickMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/22/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerKickMessage.h"

NSString* const iTetPlayerKickMessageTag =	@"kick";

@implementation iTetPlayerKickMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	// Treat second token as player number
	playerNumber = [[tokens objectAtIndex:1] integerValue];
	
	return self;
}

+ (id)messageWithPlayerNumber:(NSInteger)number
{
	return [[[self alloc] initWithPlayerNumber:number] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)number
{
	playerNumber = number;
	
	return self;
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %ld", iTetPlayerKickMessageTag, (long)[self playerNumber]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
