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

#define ITET_GENERATOR_MULTIPLIER				0x08088405UL
#define ITET_GENERATOR_INCREMENT				0x00000001UL
#define ITET_GENERATOR_MODULUS					(0x1UL << 32)

#define ITET_GENERATOR_NEXT_SEQUENCE_VALUE(v)	(((((uint64_t)(v)) * ITET_GENERATOR_MULTIPLIER) + ITET_GENERATOR_INCREMENT) % ITET_GENERATOR_MODULUS)

#define ITET_GENERATOR_TYPE_INDEXES	100UL
#define ITET_GENERATOR_ORIENTATIONS	4UL

- (iTetBlock*)generateNextBlock
{
	// Generate the next pseudorandom value in the sequence, and use it to generate an index in the block frequencies array
	sequenceValue = ITET_GENERATOR_NEXT_SEQUENCE_VALUE(sequenceValue);
	NSUInteger blockTypeIndex = ((((uint64_t)sequenceValue) * ITET_GENERATOR_TYPE_INDEXES) / ITET_GENERATOR_MODULUS);
	
	// FIXME: debug logging
	NSLog(@"DEBUG: sequence value: 0x%08X", sequenceValue);
	NSLog(@"           type index: %d", blockTypeIndex);
	
	// Generate another value, and use it to determine the block's orientation
	sequenceValue = ITET_GENERATOR_NEXT_SEQUENCE_VALUE(sequenceValue);
	NSUInteger blockOrientation = ((((uint64_t)sequenceValue) * ITET_GENERATOR_ORIENTATIONS) / ITET_GENERATOR_MODULUS);
	
	NSLog(@"       sequence value: 0x%08X", sequenceValue);
	NSLog(@"          orientation: %d", blockOrientation);
	NSLog(@"---------------------------------");
	
	// Create and return a new block using these values
	return [iTetBlock blockWithType:(iTetBlockType)[[blockFrequencies objectAtIndex:blockTypeIndex] intValue]
						orientation:blockOrientation];
}

@end
