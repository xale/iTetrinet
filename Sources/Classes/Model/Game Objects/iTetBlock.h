//
//  iTetBlock.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "IPSIntegerGeometry.h"

#define ITET_BLOCK_WIDTH	4
#define ITET_BLOCK_HEIGHT	4

typedef uint8_t BLOCK[ITET_BLOCK_HEIGHT][ITET_BLOCK_WIDTH];

#define ITET_NUM_BLOCK_TYPES	7
typedef enum
{
	I_block,
	O_block,
	J_block,
	L_block,
	Z_block,
	S_block,
	T_block
} iTetBlockType;

typedef enum
{
	moveLeft =	-1,
	moveNone =	0,
	moveRight =	1
} iTetMoveDirection;

typedef enum
{
	rotateCounterclockwise = -1,
	rotateNone = 0,
	rotateClockwise = 1
} iTetRotationDirection;

#define ITET_NUM_CELL_COLORS 5

@interface iTetBlock: NSObject <NSCopying>
{
	iTetBlockType type;
	NSInteger orientation;
	IPSCoord position;
}

// Create blocks with specific types, orientations and positions
+ (id)blockWithType:(iTetBlockType)blockType
		orientation:(NSInteger)blockOrientation
		   position:(IPSCoord)blockPosition;
- (id)initWithType:(iTetBlockType)blockType
	   orientation:(NSInteger)blockOrientation
		  position:(IPSCoord)blockPosition;

// Create blocks with specific types and orientations
+ (id)blockWithType:(iTetBlockType)blockType
		orientation:(NSInteger)blockOrientation;
- (id)initWithType:(iTetBlockType)blockType
	   orientation:(NSInteger)blockOrientation;

// Create random blocks using the frequency information from the game rules
// blockFrequencies must be of length 100
+ (id)randomBlockUsingBlockFrequencies:(NSArray*)blockFrequencies;
- (id)initWithRandomTypeAndOrientationUsingFrequencies:(NSArray*)blockFrequencies;

// Returns a copy of the receiver, shifted horizontally in the specified direction
- (iTetBlock*)blockShiftedInDirection:(iTetMoveDirection)direction;

// Returns a copy of the receiver, shifted down by one row
- (iTetBlock*)blockShiftedDown;

// Returns a copy of the reveiver, rotated in the specified direction
- (iTetBlock*)blockRotatedInDirection:(iTetRotationDirection)direction;

// Returns the contents of this block
// Note that the returned array is inverted on the vertical axis; use [(ITET_BLOCK_HEIGHT - 1) - rowIndex] to access the row at a given index
- (BLOCK*)contents;

// Returns the contents of the block at the specified indexes
- (uint8_t)cellAtRow:(NSInteger)row
			  column:(NSInteger)col;

// Returns the block's type
@property (readonly) iTetBlockType type;

// Returns the block's orientation
@property (readonly) NSInteger orientation;

// Returns the block's position
@property (readonly) IPSCoord position;

// Returns the number of possible orientations for this block
- (NSInteger)numOrientations;

// Returns the starting position offset for this block
- (NSInteger)initialColumnOffset;
- (NSInteger)initialRowOffset;

@end
