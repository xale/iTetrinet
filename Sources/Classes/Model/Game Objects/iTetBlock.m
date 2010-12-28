//
//  iTetBlock.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetBlock.h"

static BLOCK bI[2] = {
	{
		{0,0,0,0},
		{1,1,1,1},
		{0,0,0,0},
		{0,0,0,0}
	}, {
		{0,1,0,0},
		{0,1,0,0},
		{0,1,0,0},
		{0,1,0,0}
	}
};

static BLOCK bO[1] = {
	{
		{0,2,2,0},
		{0,2,2,0},
		{0,0,0,0},
		{0,0,0,0}
	}
};

static BLOCK bJ[4] = {
	{
		{3,0,0,0},
		{3,3,3,0},
		{0,0,0,0},
		{0,0,0,0}
	}, {
		{0,3,3,0},
		{0,3,0,0},
		{0,3,0,0},
		{0,0,0,0}
	}, {
		{0,0,0,0},
		{3,3,3,0},
		{0,0,3,0},
		{0,0,0,0}
	}, {
		{0,3,0,0},
		{0,3,0,0},
		{3,3,0,0},
		{0,0,0,0}
	},
};

static BLOCK bL[4] = {
	{
		{0,0,4,0},
		{4,4,4,0},
		{0,0,0,0},
		{0,0,0,0}
	}, {
		{0,4,0,0},
		{0,4,0,0},
		{0,4,4,0},
		{0,0,0,0}
	}, {
		{0,0,0,0},
		{4,4,4,0},
		{4,0,0,0},
		{0,0,0,0}
	}, {
		{4,4,0,0},
		{0,4,0,0},
		{0,4,0,0},
		{0,0,0,0}
	}
};

static BLOCK bZ[2] = {
	{
		{5,5,0,0},
		{0,5,5,0},
		{0,0,0,0},
		{0,0,0,0}
	}, {
		{0,0,5,0},
		{0,5,5,0},
		{0,5,0,0},
		{0,0,0,0}
	}
};

static BLOCK bS[2] = {
	{
		{0,1,1,0},
		{1,1,0,0},
		{0,0,0,0},
		{0,0,0,0}
	}, {
		{1,0,0,0},
		{1,1,0,0},
		{0,1,0,0},
		{0,0,0,0}
	}
};

static BLOCK bT[4] = {
	{
		{0,2,0,0},
		{2,2,2,0},
		{0,0,0,0},
		{0,0,0,0}
	}, {
		{0,2,0,0},
		{0,2,2,0},
		{0,2,0,0},
		{0,0,0,0}
	}, {
		{0,0,0,0},
		{2,2,2,0},
		{0,2,0,0},
		{0,0,0,0}
	}, {
		{0,2,0,0},
		{2,2,0,0},
		{0,2,0,0},
		{0,0,0,0}
	}
};

static BLOCK *blocks[ITET_NUM_BLOCK_TYPES] = {bI, bO, bJ, bL, bZ, bS, bT};
static NSInteger orientationCount[ITET_NUM_BLOCK_TYPES] = {2, 1, 4, 4, 2, 2, 4};

@implementation iTetBlock

+ (id)blockWithType:(iTetBlockType)blockType
		orientation:(NSInteger)blockOrientation
		   position:(IPSCoord)blockPosition
{
	return [[[self alloc] initWithType:blockType
						   orientation:blockOrientation
							  position:blockPosition] autorelease];
}

- (id)initWithType:(iTetBlockType)blockType
	   orientation:(NSInteger)blockOrientation
		  position:(IPSCoord)blockPosition
{
	type = blockType;
	orientation = (blockOrientation % orientationCount[type]);
	position = blockPosition;
	
	return self;
}

+ (id)blockWithType:(iTetBlockType)blockType
		orientation:(NSInteger)blockOrientation
{
	return [[[self alloc] initWithType:blockType
						   orientation:blockOrientation] autorelease];
}

- (id)initWithType:(iTetBlockType)blockType
	   orientation:(NSInteger)blockOrientation
{
	type = blockType;
	orientation = (blockOrientation % orientationCount[type]);
	
	return self;
}

- (id)copyWithZone:(NSZone*)zone
{
	return [[[self class] allocWithZone:zone] initWithType:type
											   orientation:orientation
												  position:position];
}

+ (id)randomBlockUsingBlockFrequencies:(NSArray*)blockFrequencies
{
	return [[[self alloc] initWithRandomTypeAndOrientationUsingFrequencies:blockFrequencies] autorelease];
}

- (id)initWithRandomTypeAndOrientationUsingFrequencies:(NSArray*)blockFrequencies
{
	NSParameterAssert(blockFrequencies != nil);
	NSParameterAssert([blockFrequencies count] == 100);
	
	type = (iTetBlockType)[[blockFrequencies objectAtIndex:(random() % [blockFrequencies count])] intValue];
	orientation = (random() % orientationCount[type]);
	
	return self;
}

#pragma mark -
#pragma mark Moving / Rotation

- (iTetBlock*)blockShiftedInDirection:(iTetMoveDirection)direction
{
	return [iTetBlock blockWithType:type
						orientation:orientation
						   position:IPSMakeCoord(position.row, (position.col + direction))];
}

- (iTetBlock*)blockShiftedDown
{
	return [iTetBlock blockWithType:type
						orientation:orientation
						   position:IPSMakeCoord((position.row - 1), position.col)];
}

- (iTetBlock*)blockRotatedInDirection:(iTetRotationDirection)direction
{
	NSInteger newOrientation = (orientation + direction + [self numOrientations]) % [self numOrientations];
	return [iTetBlock blockWithType:type
						orientation:newOrientation
						   position:position];
}

#pragma mark -
#pragma mark Accessors

- (BLOCK*)contents
{
	return &(blocks[type][orientation]);
}

- (uint8_t)cellAtRow:(NSInteger)row
			  column:(NSInteger)col
{
	return blocks[type][orientation][(ITET_BLOCK_WIDTH - 1) - row][col];
}

@synthesize type;
@synthesize orientation;
@synthesize position;

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@: type = %d, position = %@, orientation = %d", [super description], type, IPSStringFromCoord(position), orientation];
}

- (NSInteger)numOrientations
{
	return orientationCount[type];
}

- (NSInteger)initialColumnOffset
{
	// Determine whether the block needs an offset
	switch (type)
	{
			// S-blocks in orientation 1
		case S_block:
			if (orientation == 1)
				return 1;
			break;
			
			// J-, L- and T-blocks in orientation 3
		case J_block:
		case L_block:
		case T_block:
			if (orientation == 3)
				return 1;
			break;
			
		default:
			break;
	}
	
	return 0;
}

- (NSInteger)initialRowOffset
{	
	// Determine whether the block needs an offset
	switch (type)
	{
			// I-blocks in orientation 0
		case I_block:
			if (orientation == 0)
				return 1;
			break;
			
			// J-, L- and T-blocks in orientation 2
		case J_block:
		case L_block:
		case T_block:
			if (orientation == 2)
				return 1;
			break;
			
		default:
			break;
	}
	
	return 0;
}

@end
