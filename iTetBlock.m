//
//  iTetBlock.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetBlock.h"
#import "iTetField.h"

typedef char BLOCK[ITET_BLOCK_HEIGHT][ITET_BLOCK_WIDTH];

static BLOCK bI[2] = {
	{
		{0,1,0,0},
		{0,1,0,0},
		{0,1,0,0},
		{0,1,0,0}
	}, {
		{1,1,1,1},
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,0}
	}
};

static BLOCK bO[1] = {
	{
		{2,2,0,0},
		{2,2,0,0},
		{0,0,0,0},
		{0,0,0,0}
	}
};

static BLOCK bJ[4] = {
	{
		{0,3,0,0},
		{0,3,0,0},
		{3,3,0,0},
		{0,0,0,0}
	}, {
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
	}
};

static BLOCK bL[4] = {
	{
		{4,4,0,0},
		{0,4,0,0},
		{0,4,0,0},
		{0,0,0,0}
	}, {
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
	}
};

static BLOCK bZ[2] = {
	{
		{0,0,5,0},
		{0,5,5,0},
		{0,5,0,0},
		{0,0,0,0}
	}, {
		{5,5,0,0},
		{0,5,5,0},
		{0,0,0,0},
		{0,0,0,0}
	}
};

static BLOCK bS[2] = {
	{
		{1,0,0,0},
		{1,1,0,0},
		{0,1,0,0},
		{0,0,0,0}
	}, {
		{0,1,1,0},
		{1,1,0,0},
		{0,0,0,0},
		{0,0,0,0}
	}
};

static BLOCK bT[4] = {
	{
		{0,2,0,0},
		{2,2,0,0},
		{0,2,0,0},
		{0,0,0,0}
	}, {
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
	}
};

static BLOCK *blocks[ITET_NUM_BLOCK_TYPES] = {bI, bO, bJ, bL, bZ, bS, bT};
static NSInteger orientationCount[ITET_NUM_BLOCK_TYPES] = {2, 1, 4, 4, 2, 2, 4};

@implementation iTetBlock

+ (id)blockWithType:(iTetBlockType)blockType
	  orientation:(NSInteger)blockOrientation
	  rowPosition:(NSInteger)row
     columnPosition:(NSInteger)column
{
	return [[[self alloc] initWithType:blockType
				     orientation:blockOrientation
				     rowPosition:row
				  columnPosition:column] autorelease];
}

- (id)initWithType:(iTetBlockType)blockType
	 orientation:(NSInteger)blockOrientation
	 rowPosition:(NSInteger)row
    columnPosition:(NSInteger)column
{
	type = blockType;
	orientation = blockOrientation;
	rowPos = row;
	colPos = column;
	
	return self;
}

+ (id)blockWithType:(iTetBlockType)blockType
	  orientation:(NSInteger)blockOrientation
{
	return [self blockWithType:blockType
			   orientation:blockOrientation
			   rowPosition:0
			columnPosition:0];
}

- (id)initWithType:(iTetBlockType)blockType
	 orientation:(NSInteger)blockOrientation
{	
	return [self initWithType:blockType
			  orientation:blockOrientation
			  rowPosition:0
		     columnPosition:0];
}

+ (id)randomBlockUsingBlockFrequencies:(char*)blockFrequencies
{
	return [[[self alloc] initWithRandomTypeAndOrientationUsingFrequencies:blockFrequencies] autorelease];
}

- (id)initWithRandomTypeAndOrientationUsingFrequencies:(char*)blockFrequencies
{	
	type = (iTetBlockType)(blockFrequencies[random() % 100] - 1);
	orientation = (random() % orientationCount[type]);
	
	return self;
}

#pragma mark -
#pragma mark Accessors

- (char)cellAtRow:(NSInteger)row
	     column:(NSInteger)col
{
	return blocks[type][orientation][(ITET_BLOCK_WIDTH - row) - 1][col];
}

- (void)moveHorizontal:(iTetMoveDirection)direction
		   onField:(iTetField*)field
{
	// Determine the block's new position
	NSInteger newColPos = [self colPos] + direction;
	
	// Check if the block would be obstructed in the new position
	if ([field blockObstructed:[iTetBlock blockWithType:type
							    orientation:[self orientation]
							    rowPosition:[self rowPos]
							 columnPosition:newColPos]])
		return; // Block obstructed
	
	// Otherwise, move the block to the new position
	[self setColPos:newColPos];
}
- (BOOL)moveDownOnField:(iTetField*)field
{
	// Determine the block's new position
	NSInteger newRowPos = [self rowPos] - 1;
	
	// Check if the block would be obstructed in the new position
	if ([field blockObstructed:[iTetBlock blockWithType:type
							    orientation:[self orientation]
							    rowPosition:newRowPos
							 columnPosition:[self colPos]]])
	{
		// Block does not move down, but solidifies instead
		return YES;
	}
	
	// If unobstructed, move to new position
	[self setRowPos:newRowPos];
	
	return NO;
}
@synthesize rowPos, colPos;

- (void)rotate:(iTetRotationDirection)direction
	 onField:(iTetField*)field
{
	// Determine the new orientation
	NSInteger newOrientation = ([self orientation] + direction + [self numOrientations]) % [self numOrientations];
	
	// Check if the block would be obstructed in the new orientation
	switch ([field blockObstructed:[iTetBlock blockWithType:type
								  orientation:newOrientation
								  rowPosition:[self rowPos]
							     columnPosition:[self colPos]]])
	{
		case obstructVert:
			// Block cannot be rotated
			return;
			
		case obstructHoriz:
		{
			// Attempt to shift the block to accommodate rotation
			// (blatently stolen from gTetrinet source)
			NSInteger shifts[4] = {1, -1, 2, -2};
			for (NSUInteger i = 0; i < 4; i++)
			{
				if (![field blockObstructed:[iTetBlock blockWithType:type
										     orientation:newOrientation
										     rowPosition:[self rowPos]
										  columnPosition:[self colPos] + shifts[i]]])
				{
					[self setColPos:([self colPos] + shifts[i])];
					goto successfulShift;
				}
			}
			// Still can't rotate, even after shifting
			return;
		}
	}
	
	// If unobstructed, or if shifting was successful, change the orientation
successfulShift:
	[self setOrientation:newOrientation];
}
@synthesize orientation;

- (NSInteger)numOrientations
{
	return orientationCount[type];
}

- (NSInteger)initialColumnOffset
{
	// All block configurations with offsets are orientation 0
	if (orientation != 0)
		return 0;
	
	// I- and Z-blocks don't need offsets
	if ((type == I_block) || (type == Z_block))
		return 0;
	
	return 1;
}

@end
