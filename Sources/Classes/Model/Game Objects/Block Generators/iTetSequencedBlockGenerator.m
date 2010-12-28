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
	if (![super initWithBlockFrequencies:frequencies])
		return nil;
	
	sequenceValue = seed;
	
	return self;
}

#define ITET_GENERATOR_MULTIPLIER				((uint64_t)(0x08088405))
#define ITET_GENERATOR_INCREMENT				((uint64_t)(0x00000001))
#define ITET_GENERATOR_MODULUS					(((uint64_t)(0x1)) << 32)

#define ITET_GENERATOR_NEXT_SEQUENCE_VALUE(v)	(((((uint64_t)(v)) * ITET_GENERATOR_MULTIPLIER) + ITET_GENERATOR_INCREMENT) % ITET_GENERATOR_MODULUS)

#define ITET_GENERATOR_NUM_TYPE_INDEXES			((uint64_t)(100))
#define ITET_GENERATOR_NUM_ORIENTATIONS			((uint64_t)(4))

- (iTetBlock*)generateNextBlock
{
	// Generate the next pseudorandom value in the sequence, and use it to generate an index in the block frequencies array
	sequenceValue = ITET_GENERATOR_NEXT_SEQUENCE_VALUE(sequenceValue);
	NSUInteger blockTypeIndex = ((((uint64_t)sequenceValue) * ITET_GENERATOR_NUM_TYPE_INDEXES) / ITET_GENERATOR_MODULUS);
	
	// Generate another value, and use it to determine the block's orientation
	sequenceValue = ITET_GENERATOR_NEXT_SEQUENCE_VALUE(sequenceValue);
	NSUInteger blockOrientation = ((((uint64_t)sequenceValue) * ITET_GENERATOR_NUM_ORIENTATIONS) / ITET_GENERATOR_MODULUS);
	
	// Create and return a new block using the block type at the generated index, and the generated orientation
	return [iTetBlock blockWithType:(iTetBlockType)[[blockFrequencies objectAtIndex:blockTypeIndex] intValue]
						orientation:blockOrientation];
}

@end
