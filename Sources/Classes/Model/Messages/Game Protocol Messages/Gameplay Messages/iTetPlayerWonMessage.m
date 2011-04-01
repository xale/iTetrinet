//
//  iTetPlayerWonMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerWonMessage.h"

NSString* const iTetPlayerWonMessageTag =	@"playerwon";

@implementation iTetPlayerWonMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat second token as the player number
	playerNumber = [[tokens objectAtIndex:1] integerValue];
	
	return self;
}

+ (id)messageWithPlayerNumber:(NSInteger)number
{
	return [[[self alloc] initWithPlayerNumber:number] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)number
{
	if (!(self = [super init]))
		return nil;
	
	playerNumber = number;
	
	return self;
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	// Override to add message payload to outgoing messages
	return [NSString stringWithFormat:@"%@ %ld", iTetPlayerWonMessageTag, (long)[self playerNumber]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
