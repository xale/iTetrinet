//
//  iTetSequencedBlockGenerator.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/9/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetSequencedBlockGenerator.h"
#import "iTetBlock.h"

@implementation iTetSequencedBlockGenerator

- (id)initWithBlockFrequenices:(NSArray*)frequencies
				  sequenceSeed:(NSUInteger)seed
{
	blockFrequencies = [frequencies copy];
	sequenceValue = seed;
	
	return self;
}

#define ITET_GENERATOR_MULTIPLIER	0x08088405L
#define ITET_GENERATOR_INCREMENT	0x00000001L
#define ITET_GENERATOR_MODULUS		(0x1L << 32)

#define ITET_GENERATOR_TYPE_INDEXES	100L
#define ITET_GENERATOR_ORIENTATIONS	4L

- (iTetBlock*)generateNextBlock
{
	// Generate the next pseudorandom value in the sequence
	sequenceValue = (((sequenceValue * ITET_GENERATOR_MULTIPLIER) + ITET_GENERATOR_INCREMENT) % ITET_GENERATOR_MODULUS);
	
	// Use the psuedorandom value to generate an index in the block frequencies array, and a orientation
	NSUInteger blockTypeIndex = ((sequenceValue * ITET_GENERATOR_TYPE_INDEXES) / ITET_GENERATOR_MODULUS);
	NSUInteger blockOrientation = ((sequenceValue * ITET_GENERATOR_ORIENTATIONS) / ITET_GENERATOR_MODULUS);
	
	// Create and return a new block using these values
	return [iTetBlock blockWithType:(iTetBlockType)[[blockFrequencies objectAtIndex:blockTypeIndex] intValue]
						orientation:blockOrientation];
}

@end
