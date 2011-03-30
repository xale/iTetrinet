//
//  iTetNewGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/29/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNewGameMessage.h"

#import "NSArray+Subranges.h"

@implementation iTetNewGameMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Abstract class, throw an exception on instantiation
	if ([self isMemberOfClass:[iTetNewGameMessage class]])
	{
		[self doesNotRecognizeSelector:_cmd];
		[self release];
		return nil;
	}
	
	// Retain the remaining tokens from the message as the game rules
	rulesTokens = [[tokens subarrayFromIndex:1] retain];
	
	return self;
}

+ (id)messageWithRulesTokens:(NSArray*)rules
{
	return [[[self alloc] initWithRulesTokens:rules] autorelease];
}

- (id)initWithRulesTokens:(NSArray*)rules
{
	if (!(self = [super init]))
		return nil;
	
	rulesTokens = [rules copy];
	
	return self;
}

- (void)dealloc
{
	[rulesTokens release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %@", [self messageTag], [[self rulesTokens] componentsJoinedByString:@" "]];
}

#pragma mark -
#pragma mark Accessors

- (NSString*)messageTag
{
	// Abstract method; throw an exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@synthesize rulesTokens;

@end
