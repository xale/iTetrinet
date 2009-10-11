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
	L_block,
	J_block,
	S_block,
	Z_block,
	T_block
} iTetBlockType;

#define ITET_NUM_CELL_COLORS 5

@interface iTetBlock: NSObject
{
	iTetBlockType type;
	int orientation;
	int rowPos, colPos;
}

+ (id)blockWithType:(iTetBlockType)newType
	  orientation:(int)orientation;
- (id)initWithType:(iTetBlockType)newType
	 orientation:(int)newOrientation;

// Returns the contents of this block at the specified cell
- (char)cellAtRow:(int)row
	     column:(int)col;

// The block's position
@property (readonly) int rowPos;
@property (readonly) int colPos;

// Returns the number of possible orientations for this block
- (int)numOrientations;

@end
