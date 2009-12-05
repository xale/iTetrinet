//
//  iTetBlock.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import <Cocoa/Cocoa.h>

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

#define ITET_NUM_CELL_COLORS 5

@interface iTetBlock: NSObject
{
	iTetBlockType type;
	int orientation;
	int rowPos, colPos;
}

// Create blocks with specific types and orientations
+ (id)blockWithType:(iTetBlockType)newType
	  orientation:(int)orientation;
- (id)initWithType:(iTetBlockType)newType
	 orientation:(int)newOrientation;

// Create random blocks using the frequency information from the game rules
// NOTE: The frequency information must be an array of length 100
+ (id)randomBlockUsingBlockFrequencies:(char*)blockFrequencies;
- (id)initWithRandomTypeAndOrientationUsingFrequencies:(char*)blockFrequencies;

// Returns the contents of this block at the specified cell
- (char)cellAtRow:(int)row
	     column:(int)col;

// The block's position
- (void)moveLeft;
- (void)moveRight;
- (void)moveDown;
@property (readonly) int rowPos;
@property (readonly) int colPos;

// The block's present orientation (rotation)
- (void)rotateClockwise;
- (void)rotateCounterclockwise;
@property (readonly) int orientation;

// Returns the number of possible orientations for this block
- (int)numOrientations;

@end
