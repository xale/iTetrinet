//
//  iTetField.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetField.h"
#import "iTetBlock.h"
#import "iTetSpecials.h"

// For the partial update string, rows are indexed from '3' (decimal 51), top to bottom...
#define ITET_PARTIAL_ROW(row)	((ITET_FIELD_HEIGHT - row) + '3')
// ...columns from '3' (51), right to left...
#define ITET_PARTIAL_COL(col)	((ITET_FIELD_WIDTH - col) + '3')
// ...and the cell contents are mapped to different characters
char partialUpdateCell(char cellType);

@implementation iTetField

+ (id)field
{
	return [[[self alloc] init] autorelease];
}

#pragma mark Fields with Starting Stack

+ (id)fieldWithStackHeight:(int)stackHeight
{
	return [[[self alloc] initWithStackHeight:stackHeight] autorelease];
}

- (id)initWithStackHeight:(int)stackHeight
{	
	// For each row of the starting stack, fill with debris
	// Uses gtetrinet's method; bizarre, but whatever
	for (int row = 0; row < stackHeight; row++)
	{
		// Fill the row randomly
		for (int col = 0; col < ITET_FIELD_WIDTH; col++)
			contents[row][col] = random() % (ITET_NUM_CELL_COLORS + 1);
		
		// Choose a random column index
		int emptyCol = random() % ITET_FIELD_WIDTH;
		
		// Ensure that at least one column index is empty
		contents[row][emptyCol] = 0;
	}
	
	return self;
}

#pragma mark Random Fields

+ (id)fieldWithRandomContents
{
	return [[[self alloc] initWithRandomContents] autorelease];
}

- (id)initWithRandomContents
{	
	for (int row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (int col = 0; col < ITET_FIELD_WIDTH; col++)
		{	
			contents[row][col] = (random() % ITET_NUM_CELL_COLORS) + 1;
		}
	}
		
	
	return self;
}

#pragma mark Copying Fields

- (id)copyWithZone:(NSZone*)zone
{
	return [[[self class] allocWithZone:zone] initWithContents:contents];
}

- (id)initWithContents:(char[ITET_FIELD_HEIGHT][ITET_FIELD_WIDTH])fieldContents
{	
	memcpy(contents, fieldContents, (ITET_FIELD_WIDTH * ITET_FIELD_HEIGHT) * sizeof(char));
	
	return self;
}

- (void)dealloc
{
	[lastPartialUpdate release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Obstruction Testing

- (iTetObstructionState)blockObstructed:(iTetBlock*)block
{
	int row, col;
	char cell;
	iTetObstructionState side = obstructNone;
	
	// For each cell in the block, check if it is obstructed on the field
	for (row = 0; row < ITET_BLOCK_HEIGHT; row++)
	{
		for (col = 0; col < ITET_BLOCK_WIDTH; col++)
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
						
					// If unobstructed, keep checking
					default:
						break;
				}
			}
		}
	}
	
	// If no vertical obstructions were found, return whether or not we found any horizontal obstructions
	return side;
}

- (iTetObstructionState)cellObstructedAtRow:(int)row
					   column:(int)col
{
	// Check if obstructed by sides of field
	if ((col < 0) || (col >= ITET_FIELD_WIDTH))
		return obstructHoriz;
	
	// Check if obstructed by top/bottom of field
	if ((row < 0) || (row >= ITET_FIELD_HEIGHT))
		return obstructVert;
	
	// Check if the cell is occupied
	if (contents[row][col])
		return obstructVert;
	
	return obstructNone;
}

#pragma mark -
#pragma mark Accessors

- (void)solidifyBlock:(iTetBlock*)block
{
	int row, col;
	char cell, lastCell = 0;
	
	NSMutableString* update = [NSMutableString string];
	
	for (row = 0; row < ITET_BLOCK_HEIGHT; row++)
	{
		for (col = 0; col < ITET_BLOCK_WIDTH; col++)
		{
			cell = [block cellAtRow:row column:col];
			if (cell)
			{
				// Add this cell of the block to the field
				contents[[block rowPos] + row][[block colPos] + col] = cell;
				
				// If this cell is a different "color" from the last one in the partial update, add that information to the update string
				if (cell != lastCell)
				{
					[update appendFormat:@"%c", partialUpdateCell(cell)];
					lastCell = cell;
				}
					
				// Add the changed cell's coordinates to the update string
				[update appendFormat:@"%c%c", ITET_PARTIAL_ROW(row), ITET_PARTIAL_COL(col)];
			}
		}
	}
	
	// Retain this as the most recent partial update
	[self setLastPartialUpdate:update];
}

- (char)cellAtRow:(int)row
	     column:(int)col
{
	return contents[row][col];
}

- (NSString*)fieldstring
{
	NSMutableString* field = [NSMutableString stringWithCapacity:(ITET_FIELD_WIDTH * ITET_FIELD_HEIGHT)];
	
	char cell;
	// Iterate over the whole field
	for (int row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (int col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// Get the contents of this cell
			cell = contents[row][col];
			
			// If the cell contains a special, add the special's letter to the fieldstring
			if (cell > ITET_NUM_CELL_COLORS)
				[field appendFormat:@"%c", cell];
			// Otherwise, add the cell's numeric value
			else
				[field appendFormat:@"%d", cell];
		}
	}
	
	// Return the completed fieldstring
	return [NSString stringWithString:field];
}

char partialUpdateCell(char cellType)
{
	// Special cells map to a sequential set of ASCII characters, which sadly means we can't just do an add or subtract
	switch ((iTetSpecialType)cellType)
	{
		case addLine:
			return '\'';
		case clearLine:
			return '(';
		case nukeField:
			return ')';
		case randomClear:
			return '*';
		case switchField:
			return '+';
		case clearSpecials:
			return ',';
		case gravity:
			return '-';
		case quakeField:
			return '.';
		case blockBomb:
			return '/';
	}
	
	// Non-special cells are indexed from ASCII 33 ('!')
	return (cellType + 33);
}

@synthesize lastPartialUpdate;

@end
