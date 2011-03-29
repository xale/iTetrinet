//
//  iTetRandomBlockGenerator.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/9/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetRandomBlockGenerator.h"
#import "iTetBlock.h"

@implementation iTetRandomBlockGenerator

- (id)init
{
	return [self initWithBlockFrequencies:nil];
}

- (id)initWithBlockFrequencies:(NSArray*)frequencies
{
	if (!(self = [super init]))
		return nil;
	
	// Check that we have been provided a frequency list
	if ((frequencies == nil) || ([frequencies count] == 0))
	{
		@throw [NSException exceptionWithName:NSInvalidArgumentException
									   reason:nil
									 userInfo:nil];
	}
	
	blockFrequencies = [frequencies copy];
	
	return self;
}

- (void)dealloc
{
	[blockFrequencies release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (iTetBlock*)generateNextBlock
{
	return [iTetBlock randomBlockUsingBlockFrequencies:blockFrequencies];
}

@end
