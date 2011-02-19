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
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

- (id)initWithBlockFrequencies:(NSArray*)frequencies
{
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
