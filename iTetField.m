//
//  iTetField.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetField.h"
#import "iTetBlock.h"
#import "iTetSpecials.h"

// For the partial update string, rows and columns are reverse-indexed from '3' (decimal 51)...
// (conveniently, this function is its own inverse)
#define ITET_CONVERT_ROW(coord)	(((ITET_FIELD_HEIGHT - 1) - (coord)) + '3')
#define ITET_CONVERT_COL(coord)	(((ITET_FIELD_WIDTH - 1) - (coord)) + '3')
// ...and the cell contents are mapped to different characters
char cellToPartialUpdateChar(char cellType);
char partialUpdateCharToCell(char updateChar);

@implementation iTetField

+ (id)field
{
	return [[[self alloc] init] autorelease];
}

#pragma mark Fields from a Fieldstring
+ (id)fieldFromFieldstring:(NSString*)fieldstring
{
	return [[[self alloc] initWithFieldstring:fieldstring] autorelease];
}

- (id)initWithFieldstring:(NSString*)fieldstring
{
	// Convert the field string to a standard ASCII C string
	const char* field = [fieldstring cStringUsingEncoding:NSASCIIStringEncoding];
	char currentCell;
	
	// Iterate through the fieldstring
	NSUInteger row, col;
	for (NSUInteger i = 0; i < [fieldstring length]; i++)
	{
		// Get the cell value at this index
		currentCell = field[i];
		
		// If the current cell is a numeric value, convert
		if (isdigit(currentCell))
			currentCell -= '0';
		
		// Find the coordinates this index corresponds to
		row = (ITET_FIELD_HEIGHT - 1) - (i / ITET_FIELD_WIDTH);
		col = i % ITET_FIELD_WIDTH;
		
		// Set the cell at those coordinates to the value at this index
		contents[row][col] = currentCell;
	}
	
	
	return self;
}

#pragma mark Fields with Starting Stack

+ (id)fieldWithStackHeight:(NSUInteger)stackHeight
{
	return [[[self alloc] initWithStackHeight:stackHeight] autorelease];
}

- (id)initWithStackHeight:(NSUInteger)stackHeight
{	
	// For each row of the starting stack, fill with debris
	// Uses gtetrinet's method; bizarre, but whatever
	for (NSUInteger row = 0; row < stackHeight; row++)
	{
		// Fill the row randomly
		for (NSUInteger col = 0; col < ITET_FIELD_WIDTH; col++)
			contents[row][col] = random() % (ITET_NUM_CELL_COLORS + 1);
		
		// Choose a random column index
		NSUInteger emptyCol = random() % ITET_FIELD_WIDTH;
		
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
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
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
	memcpy(contents, fieldContents, sizeof(fieldContents));
	
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
	NSInteger row, col;
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
#pragma mark Board Changes/Updates

- (void)solidifyBlock:(iTetBlock*)block
{
	NSInteger row, col;
	char cell, lastCell = 0;
	char rowCoord, colCoord;
	
	NSMutableString* update = [NSMutableString string];
	
	[self willChangeValueForKey:@"contents"];
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
					[update appendFormat:@"%c", cellToPartialUpdateChar(cell)];
					lastCell = cell;
				}
					
				// Add the changed cell's coordinates to the update string
				rowCoord = ITET_CONVERT_ROW([block rowPos] + row);
				colCoord = ITET_CONVERT_COL([block colPos] + col);
				[update appendFormat:@"%c%c", colCoord, rowCoord];
			}
		}
	}
	[self didChangeValueForKey:@"contents"];
	
	// Retain this as the most recent partial update
	[self setLastPartialUpdate:update];
}

- (NSUInteger)clearLinesAndRetrieveSpecials:(NSMutableArray*)specials
{	
	NSUInteger linesCleared = 0;
	
	[self willChangeValueForKey:@"contents"];
	
	// Scan the field for complete lines
	NSUInteger row, col;
	for (row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			if (contents[row][col] == 0)
				break;
		}
		
		// If all cells in this row are filled...
		if (col == ITET_FIELD_WIDTH)
		{
			// ...increment the number of cleared lines...
			linesCleared++;
			
			// ...and scan for specials
			char cell;
			for (col = 0; col < ITET_FIELD_WIDTH; col++)
			{
				cell = contents[row][col];
				if (cell > ITET_NUM_CELL_COLORS)
					[specials addObject:[NSNumber numberWithChar:cell]];
			}
		}
		// Otherwise, move the line down by the number of lines cleared below it
		else if (linesCleared > 0)
		{
			// Move the row
			memcpy(contents[row - linesCleared], contents[row], sizeof(contents[row]));
			
			// Clear the row's previous location
			memset(contents[row], 0, sizeof(contents[row]));
		}
	}
	
	[self didChangeValueForKey:@"contents"];
	
	return linesCleared;
}

- (void)applyPartialUpdate:(NSString *)partialUpdate
{
	[self willChangeValueForKey:@"contents"];
	
	// Get the first type of cell we are adding
	const char* update = [partialUpdate cStringUsingEncoding:NSASCIIStringEncoding];
	char cellType = partialUpdateCharToCell(update[0]);
	
	char currentChar;
	NSUInteger row, col;
	for (NSUInteger i = 1; i < [partialUpdate length]; i++)
	{
		currentChar = update[i];
		
		// Check if this character specifies a new cell type
		if ((currentChar >= 0x21) && (currentChar <= 0x2F))
		{
			cellType = partialUpdateCharToCell(currentChar);
		}
		// If not, this character is a column-index, and the next is a row-index
		else
		{
			// Convert to our coordinate system
			col = ITET_CONVERT_COL(currentChar);
			row = ITET_CONVERT_ROW(update[i+1]);
			
			// Change the cell on the field at the specified coordinates
			contents[row][col] = cellType;
			
			// Skip the next character (we just used it)
			i++;
		}
	}
	
	[self didChangeValueForKey:@"contents"];
	
	[self setLastPartialUpdate:partialUpdate];
}

- (void)addSpecials:(NSInteger)count
   usingFrequencies:(char*)specialFrequencies
{
	[self willChangeValueForKey:@"contents"];
	
	// Count the number of non-special filled cells on the board
	NSInteger row, col, numNonSpecialCells = 0;
	char cell;
	for (row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			cell = contents[row][col];
			if ((cell > 0) && (cell < ITET_NUM_CELL_COLORS))
				numNonSpecialCells++;
		}
	}
	
	// Attempt to add the specified number of specials
	for (NSInteger specialsAdded = 0; specialsAdded < count; specialsAdded++)
	{
		// If there are non-special cells on the board, replace one at random with a special
		if (numNonSpecialCells > 0)
		{
			// Choose a random number of cells to pass over before dropping the special
			NSInteger cellsLeftToSkip = random() % numNonSpecialCells;
			
			// Iterate over the board
			for (row = 0; row < ITET_FIELD_HEIGHT; row++)
			{
				for (col = 0; col < ITET_FIELD_WIDTH; col++)
				{
					// If this is a non-special cell, check whether to add the special
					cell = contents[row][col];
					if ((cell > 0) && (cell < ITET_NUM_CELL_COLORS))
					{
						// If we have skipped the predetermined number of cells, add the special
						if (cellsLeftToSkip == 0)
						{
							// Replace the cell with a random special
							contents[row][col] = specialFrequencies[random() % 100];
							
							// Decrement the number of non-special cells remaining
							numNonSpecialCells--;
							
							// Jump to the next iteration of the special-adding loop
							goto nextspecial;
						}
						
						// Haven't reached the predetermined number of cells yet
						cellsLeftToSkip--;
					}
				}
			}
		}
		else
		{
			// Make 20 attempts to find an empty column
			NSInteger tries;
			for (tries = 0; tries < 20; tries++)
			{
				// Choose a random column
				col = random() % ITET_FIELD_WIDTH;
				
				// Check if the column is empty
				for (row = 0; row < ITET_FIELD_HEIGHT; row++)
				{
					if (contents[row][col] > 0)
						break;
				}
				
				// If the column was empty, add the new special
				if (row == ITET_FIELD_HEIGHT)
				{
					// Add the new special to the bottom row
					contents[0][col] = specialFrequencies[random() % 100];
					
					// Go to the next iteration of the special-adding loop
					goto nextspecial;
				}
			}
			// If we've tried 20 times and not found an empty column, abandon adding more specials
			if (tries == 20)
				goto abort;
		}
		
	nextspecial:; // Next iteration of special-adding loop
	}
abort:; // Unable to add more specials; bail

	[self didChangeValueForKey:@"contents"];
}

#pragma mark Specials

- (BOOL)addLines:(NSInteger)linesToAdd
{
	[self willChangeValueForKey:@"contents"];
	
	BOOL playerLost = NO;
	
	// Repeat for each line to add
	NSInteger row, col;
	for (NSInteger linesAdded = 0; linesAdded < linesToAdd; linesAdded++)
	{
		// Check the top row to see if the player has lost
		row = (ITET_FIELD_HEIGHT - 1);
		for (col = 0; !playerLost && (col < ITET_FIELD_WIDTH); col++)
		{
			// If any cell is filled, adding the next line will overflow
			if (contents[row][col] > 0)
				playerLost = YES;
		}
		
		// Shift all rows up
		for (row = (ITET_FIELD_HEIGHT - 2); row >= 0; row--)
		{
			// Copy this row to the row above
			memcpy(contents[row + 1], contents[row], sizeof(contents[row]));
		}
		
		// Fill the bottom row randomly
		for (NSUInteger col = 0; col < ITET_FIELD_WIDTH; col++)
			contents[0][col] = random() % (ITET_NUM_CELL_COLORS + 1);
		
		// Choose a random column index
		NSUInteger emptyCol = random() % ITET_FIELD_WIDTH;
		
		// Ensure that at least one column index is empty
		contents[0][emptyCol] = 0;
	}
	
	[self didChangeValueForKey:@"contents"];
	
	return playerLost;
}

#pragma mark -
#pragma mark Accessors

- (char)cellAtRow:(NSUInteger)row
	     column:(NSUInteger)col
{
	return contents[row][col];
}

- (NSString*)fieldstring
{
	NSMutableString* field = [NSMutableString stringWithCapacity:(ITET_FIELD_WIDTH * ITET_FIELD_HEIGHT)];
	
	char cell;
	// Iterate over the whole field (TOP TO BOTTOM)
	for (NSInteger row = (ITET_FIELD_HEIGHT - 1); row >= 0; row--)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
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

char cellToPartialUpdateChar(char cellType)
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

char partialUpdateCharToCell(char updateChar)
{
	// Switch to see if the update character maps to a special type
	switch (updateChar)
	{
		case '\'':
			return (char)addLine;
		case '(':
			return (char)clearLine;
		case ')':
			return (char)nukeField;
		case '*':
			return (char)randomClear;
		case '+':
			return (char)switchField;
		case ',':
			return (char)clearSpecials;
		case '-':
			return (char)gravity;
		case '.':
			return (char)quakeField;
		case '/':
			return (char)blockBomb;
	}
	
	// Otherwise, just reverse-index from ASCII 33
	return (updateChar - 33);
}

@synthesize lastPartialUpdate;

@end
