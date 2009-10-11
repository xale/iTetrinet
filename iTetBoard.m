//
//  iTetBoard.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetBoard.h"
#import "iTetBlock.h"

@implementation iTetBoard

+ (id)board
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	for (int row = 0; row < ITET_BOARD_HEIGHT; row++)
		memset((void*)(contents[row]), 0, ITET_BOARD_WIDTH);
	
	return self;
}

#pragma mark Random Boards

+ (id)boardWithRandomContents
{
	return [[[self alloc] initWithRandomContents] autorelease];
}

- (id)initWithRandomContents
{
	for (int row = 0; row < ITET_BOARD_HEIGHT; row++)
		for (int col = 0; col < ITET_BOARD_WIDTH; col++)
			contents[row][col] = (random() % ITET_NUM_CELL_COLORS) + 1;
	
	return self;
}

#pragma mark Duplicate Boards

+ (id)boardWithBoard:(iTetBoard*)board
{
	return [[[self alloc] initWithBoard:board] autorelease];
}

- (id)initWithBoard:(iTetBoard*)board
{
	for (int row; row < ITET_BOARD_HEIGHT; row++)
		for (int col; row < ITET_BOARD_WIDTH; col++)
			contents[row][col] = [board cellAtRow:row column:col];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

- (void)placeBlock:(iTetBlock*)block
{
	int row, col;
	char cell;
	for (row = 0; row < ITET_BLOCK_HEIGHT; row++)
	{
		for (col = 0; col < ITET_BLOCK_WIDTH; col++)
		{
			cell = [block cellAtRow:row column:col];
			if (cell)
				contents[[block rowPos] + row][[block colPos] + col] = cell;
		}
	}
}

- (char)cellAtRow:(int)row
	     column:(int)col
{
	return contents[row][col];
}

#pragma mark -
#pragma mark Obstruction Testing

- (ObstructionState)blockObstructed:(iTetBlock*)block
{
	int row, col;
	char cell;
	ObstructionState side = obstructNone;
	
	// For each cell in the block, check if it is obstructed on this board
	for (row = 0; row < ITET_BLOCK_HEIGHT; row++)
	{
		for (col = 0; col < ITET_BLOCK_WIDTH; row++)
		{
			cell = [block cellAtRow:row column:col];
			if (cell)
			{
				switch ([self cellObstructedAtRow:([block rowPos] + row)
								   column:([block colPos] + col)])
				{
					// If obstructed vertically, return immediately
					case obstructVert:
						return obstructVert;
						
					// If obstructed horizontally, make a note, but keep checking
					case obstructHoriz:
						side = obstructHoriz;
					
					// If unobstructed, ignore and keep checking
					default:
						break;
				}
			}
		}
	}
	
	// If no vertical obstructions were found, return whether or not we found
	// any horizontal obstructions
	return side;
}

- (ObstructionState)cellObstructedAtRow:(int)row
					   column:(int)col
{
	// Check if obstructed by sides of board
	if ((col < 0) || (col >= ITET_BOARD_WIDTH))
		return obstructHoriz;
	
	// Check if obstructed by top/bottom of board
	if ((row < 0) || (row >= ITET_BOARD_HEIGHT))
		return obstructVert;
	
	// Check if the cell is occupied
	if (contents[row][col])
		return obstructVert;
	
	return obstructNone;
}

@end
