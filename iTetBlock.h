//
//  iTetBlock.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetField;

#define ITET_BLOCK_WIDTH	4
#define ITET_BLOCK_HEIGHT	4

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
	NSInteger rowPos, colPos;
}

// Create blocks with specific types, orientations and positions
+ (id)blockWithType:(iTetBlockType)blockType
		orientation:(NSInteger)blockOrientation
		rowPosition:(NSInteger)row
     columnPosition:(NSInteger)column;
- (id)initWithType:(iTetBlockType)blockType
	   orientation:(NSInteger)blockOrientation
	   rowPosition:(NSInteger)row
    columnPosition:(NSInteger)column;

// Create blocks with specific types and orientations
+ (id)blockWithType:(iTetBlockType)blockType
		orientation:(NSInteger)blockOrientation;
- (id)initWithType:(iTetBlockType)blockType
	   orientation:(NSInteger)blockOrientation;

// Create random blocks using the frequency information from the game rules
// blockFrequencies must be of length 100
+ (id)randomBlockUsingBlockFrequencies:(uint8_t*)blockFrequencies;
- (id)initWithRandomTypeAndOrientationUsingFrequencies:(uint8_t*)blockFrequencies;

// Returns the contents of this block at the specified cell
- (uint8_t)cellAtRow:(NSInteger)row
			  column:(NSInteger)col;

// The block's position
- (void)moveHorizontal:(iTetMoveDirection)direction
			   onField:(iTetField*)field;
- (BOOL)moveDownOnField:(iTetField*)field;
@property (readwrite, assign) NSInteger rowPos;
@property (readwrite, assign) NSInteger colPos;

// The block's present orientation (rotation)
- (void)rotate:(iTetRotationDirection)direction
	   onField:(iTetField*)field;
@property (readwrite, assign) NSInteger orientation;

// Returns the number of possible orientations for this block
- (NSInteger)numOrientations;

// Returns the starting position offset for this block
- (NSInteger)initialColumnOffset;
- (NSInteger)initialRowOffset;

@end
