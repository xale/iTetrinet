//
//  iTetBoard.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import <Cocoa/Cocoa.h>

#define ITET_BOARD_WIDTH	12
#define ITET_BOARD_HEIGHT	22

typedef enum
{
	obstructNone,
	obstructVert,
	obstructHoriz
} ObstructionState;

@class iTetBlock;

@interface iTetBoard: NSObject
{
	char contents[ITET_BOARD_HEIGHT][ITET_BOARD_WIDTH];
}

// Initializer for an empty board
+ (id)board;

// Initializers for a board with a starting stack height
+ (id)boardWithStackHeight:(int)stackHeight;
- (id)initWithStackHeight:(int)stackHeight;

// Initializers for a random board
+ (id)boardWithRandomContents;
- (id)initWithRandomContents;

// Initializers for copying an existing board
+ (id)boardWithBoard:(iTetBoard*)board;
- (id)initWithBoard:(iTetBoard*)board;

// Add the cells of the specified block to the board's contents
- (void)solidifyBlock:(iTetBlock*)block;

// Returns the contents of the specified cell of the board
- (char)cellAtRow:(int)row
	     column:(int)column;

// Checks whether a block is in a valid position on the board
- (ObstructionState)blockObstructed:(iTetBlock*)block;

// Checks whether the specified cell is valid (i.e., on the board) and empty
- (ObstructionState)cellObstructedAtRow:(int)row
					   column:(int)col;

@end
