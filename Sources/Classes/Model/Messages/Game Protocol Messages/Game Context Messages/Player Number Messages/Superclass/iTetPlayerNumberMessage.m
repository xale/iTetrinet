//
//  iTetPlayerNumberMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerNumberMessage.h"

@implementation iTetPlayerNumberMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Abstract class; throw an exception on instantiation
	if ([self isMemberOfClass:[iTetPlayerNumberMessage class]])
	{
		[self doesNotRecognizeSelector:_cmd];
		[self release];
		return nil;
	}
	
	// Treat the second token as the player number
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
	
	// Abstract class; throw an exception on instantiation
	if ([self isMemberOfClass:[iTetPlayerNumberMessage class]])
	{
		[self doesNotRecognizeSelector:_cmd];
		[self release];
		return nil;
	}
	
	playerNumber = number;
	
	return self;
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %ld", [self messageTag], (long)[self playerNumber]];
}

- (NSString*)messageTag
{
	// Abstract method; throw exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
