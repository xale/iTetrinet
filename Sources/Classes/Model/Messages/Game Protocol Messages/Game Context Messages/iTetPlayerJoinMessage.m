//
//  iTetPlayerJoinMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerJoinMessage.h"

NSString* const iTetPlayerJoinMessageTag =	@"playerjoin";

@implementation iTetPlayerJoinMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	// Treat the second and third tokens as the player number and nickname, respectively
	playerNumber = [[tokens objectAtIndex:1] integerValue];
	playerNickname = [[tokens objectAtIndex:2] copy];
	
	return self;
}

+ (id)messageWithPlayerNumber:(NSInteger)number
					 nickname:(NSString*)nickname
{
	return [[[self alloc] initWithPlayerNumber:number
									  nickname:nickname] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)number
				  nickname:(NSString*)nickname
{
	playerNumber = number;
	playerNickname = [nickname copy];
	
	return self;
}

- (void)dealloc
{
	[playerNickname release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %ld %@", iTetPlayerJoinMessageTag, (long)[self playerNumber], [self playerNickname]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize playerNickname;

@end
