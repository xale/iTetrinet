//
//  iTetGameContext.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGameContext.h"

@implementation iTetGameContext

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	// Abstract class: throw an exception on instantiation
	if ([self isMemberOfClass:[iTetGameContext class]])
	{
		[self doesNotRecognizeSelector:_cmd];
		[self release];
		return nil;
	}
	
	return self;
}

- (void)dealloc
{
	[game release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isOfflineContext
{
	// Abstract method: throw an exception
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@synthesize game;

- (BOOL)gameInProgress
{
	return ([self game] != nil);
}
+ (NSSet*)keyPathsForValuesAffectingGameInProgress
{
	return [NSSet setWithObject:@"game"];
}

@end
