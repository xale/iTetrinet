//
//  iTetField.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetField.h"
#import "iTetBlock.h"

// For the partial update string, rows and columns are reverse-indexed from '3' (decimal 51)...
// (conveniently, the row function is its own inverse)
#define ITET_CONVERT_ROW(coord)		(((ITET_FIELD_HEIGHT - 1) - (coord)) + '3')
#define ITET_PARTIAL_TO_COL(coord)	((coord) - '3')
#define ITET_COL_TO_PARTIAL(coord)	((coord) + '3')
// ...and the cell contents are mapped to different characters
char cellToPartialUpdateChar(uint8_t cellType);
uint8_t partialUpdateCharToCell(char updateChar);

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
	char currentChar;
	uint8_t currentCell;
	
	// Iterate through the fieldstring
	NSInteger row, col;
	for (NSUInteger i = 0; i < [fieldstring length]; i++)
	{
		// Get the cell value at this index
		currentChar = field[i];
		
		// If the current cell is a numeric value, convert to its integer value
		if (isdigit(currentChar))
			currentCell = currentChar - '0';
		// Otherwise, just cast
		else
			currentCell = (uint8_t)currentChar;
		
		// Find the coordinates this index corresponds to
		row = (ITET_FIELD_HEIGHT - 1) - (i / ITET_FIELD_WIDTH);
		col = i % ITET_FIELD_WIDTH;
		
		// Set the cell at those coordinates to the value at this index
		contents[row][col] = currentCell;
	}
	
	
	return self;
}

#pragma mark Fields with Starting Stack

+ (id)fieldWithStackHeight:(NSInteger)stackHeight
{
	return [[[self alloc] initWithStackHeight:stackHeight] autorelease];
}

- (id)initWithStackHeight:(NSInteger)stackHeight
{	
	// For each row of the starting stack, fill with debris
	// Uses gtetrinet's method; bizarre, but whatever
	for (NSInteger row = 0; row < stackHeight; row++)
	{
		// Fill the row randomly
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
			contents[row][col] = random() % (ITET_NUM_CELL_COLORS + 1);
		
		// Choose a random column index
		NSInteger emptyCol = random() % ITET_FIELD_WIDTH;
		
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

- (id)initWithContents:(uint8_t[ITET_FIELD_HEIGHT][ITET_FIELD_WIDTH])fieldContents
{	
	memcpy(contents, fieldContents, (ITET_FIELD_HEIGHT * ITET_FIELD_WIDTH * sizeof(uint8_t)));
	
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
	uint8_t cell;
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

- (iTetObstructionState)cellObstructedAtRow:(NSInteger)row
									 column:(NSInteger)col
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
	uint8_t cell, lastCell = 0;
	NSInteger rowCoord, colCoord;
	
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
				colCoord = ITET_COL_TO_PARTIAL([block colPos] + col);
				[update appendFormat:@"%c%c", colCoord, rowCoord];
			}
		}
	}
	
	[self didChangeValueForKey:@"contents"];
	
	// Retain this as the most recent partial update
	[self setLastPartialUpdate:update];
}

- (NSInteger)clearLinesAndRetrieveSpecials:(NSMutableArray*)specials
{	
	NSInteger linesCleared = 0;
	
	[self willChangeValueForKey:@"contents"];
	
	// Scan the field for complete lines, bottom-to-top
	NSInteger row, col;
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
			if (specials != nil)
			{
				uint8_t cell;
				for (col = 0; col < ITET_FIELD_WIDTH; col++)
				{
					cell = contents[row][col];
					if (cell > ITET_NUM_CELL_COLORS)
						[specials addObject:[NSNumber numberWithUnsignedChar:cell]];
				}
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

- (void)clearLines
{
	[self clearLinesAndRetrieveSpecials:nil];
}

- (void)applyPartialUpdate:(NSString *)partialUpdate
{
	// Check that the update is not blank (some clients send blank updates)
	if ([partialUpdate length] == 0)
		return;
	
	[self willChangeValueForKey:@"contents"];
	
	// Get the first type of cell we are adding
	const char* update = [partialUpdate cStringUsingEncoding:NSASCIIStringEncoding];
	char currentChar = update[0];
	uint8_t cellType = partialUpdateCharToCell(currentChar);
	
	NSInteger row, col;
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
			col = ITET_PARTIAL_TO_COL(currentChar);
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
   usingFrequencies:(iTetSpecialType*)specialFrequencies
{
	[self willChangeValueForKey:@"contents"];
	
	// Count the number of non-special filled cells on the board
	NSInteger row, col, numNonSpecialCells = 0;
	uint8_t cell;
	for (row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			cell = contents[row][col];
			if ((cell > 0) && (cell <= ITET_NUM_CELL_COLORS))
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
					if ((cell > 0) && (cell <= ITET_NUM_CELL_COLORS))
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
		   style:(iTetLineAddStyle)style
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
		
		// Shift all rows (except the top row) up
		for (row = (ITET_FIELD_HEIGHT - 2); row >= 0; row--)
		{
			// Copy this row to the row above
			memcpy(contents[row + 1], contents[row], sizeof(contents[row]));
		}
		
		// Determine what style of line add to perform
		if (style == classicStyle)
		{
			// Fill the bottom row completely
			for (col = 0; col < ITET_FIELD_WIDTH; col++)
				contents[0][col] = (random() % ITET_NUM_CELL_COLORS) + 1;
			
			// Clear a random cell in the row
			contents[0][(random() % ITET_FIELD_WIDTH)] = 0;
		}
		else
		{
			// Fill the bottom row randomly
			for (col = 0; col < ITET_FIELD_WIDTH; col++)
				contents[0][col] = random() % (ITET_NUM_CELL_COLORS + 1);
			
			// Ensure that at least one column index is empty
			contents[0][(random() % ITET_FIELD_WIDTH)] = 0;
		}
	}
	
	[self didChangeValueForKey:@"contents"];
	
	return playerLost;
}

- (void)clearBottomLine
{
	[self willChangeValueForKey:@"contents"];
	
	// Shift all lines (except the bottom) down
	for (NSInteger row = 1; row < ITET_FIELD_HEIGHT; row++)
	{
		// Move this row to the row below
		memcpy(contents[row - 1], contents[row], sizeof(contents[row]));
	}
	
	// Clear the top line
	memset(contents[(ITET_FIELD_HEIGHT - 1)], 0, sizeof(contents[(ITET_FIELD_HEIGHT - 1)]));
	
	[self didChangeValueForKey:@"contents"];
}

#define ITET_NUM_RANDOM_CLEARS	(10)

- (void)clearRandomCells
{
	[self willChangeValueForKey:@"contents"];
	
	// Clear ten random cells on the field
	for (NSInteger cellsCleared = 0; cellsCleared < ITET_NUM_RANDOM_CLEARS; cellsCleared++)
		contents[(random() % ITET_FIELD_HEIGHT)][(random() % ITET_FIELD_WIDTH)] = 0;
	
	[self didChangeValueForKey:@"contents"];
}

#define ITET_NUM_CLEAR_ROWS	(6)

- (void)shiftClearTopSixRows
{
	// Find the highest row among the top six with an occupied cell
	NSInteger row, col, rowsToShift = 0;
	for (row = (ITET_FIELD_HEIGHT - 1); row > ((ITET_FIELD_HEIGHT - 1) - ITET_NUM_CLEAR_ROWS); row--)
	{
		for (col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			if (contents[row][col] > 0)
			{
				rowsToShift = row - ((ITET_FIELD_HEIGHT - 1) - ITET_NUM_CLEAR_ROWS);
				goto cellfound;
			}
		}
	}
cellfound:
	
	// Shift the field down
	[self shiftAllRowsDownByAmount:rowsToShift];
}

- (void)shiftAllRowsDownByAmount:(NSInteger)shiftAmount
{
	if (shiftAmount == 0)
		return;
	
	[self willChangeValueForKey:@"contents"];
	
	// Iterate over rows on the field, bottom to top, and shift them down
	NSInteger row;
	for (row = shiftAmount; row < ITET_FIELD_HEIGHT; row++)
	{
		// Move the row down
		memcpy(contents[row - shiftAmount], contents[row], sizeof(contents[row]));
	}
	
	// Clear the rows that haven't been overwritten
	for (row = (ITET_FIELD_HEIGHT - shiftAmount); row < ITET_FIELD_HEIGHT; row++)
	{
		// Clear the row
		memset(contents[row], 0, sizeof(contents[row]));
	}
	
	[self didChangeValueForKey:@"contents"];
}

- (void)removeAllSpecials
{
	[self willChangeValueForKey:@"contents"];
	
	// Iterate over the field
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// If this cell is a special, replace it with a random normal cell
			if (contents[row][col] > ITET_NUM_CELL_COLORS)
				contents[row][col] = (random() % ITET_NUM_CELL_COLORS) + 1;
		}
	}
	
	[self didChangeValueForKey:@"contents"];
}

- (void)pullCellsDown
{
	[self willChangeValueForKey:@"contents"];
	
	// Iterate over the field in column-row order (my apologies to the CPU cache)
	NSInteger gapsBelow;
	for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
	{
		// Scan the column for gaps, bottom-to-top
		gapsBelow = 0;
		for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
		{
			// If the cell is empty, increment the number of gaps in the column
			if (contents[row][col] == 0)
			{
				gapsBelow++;
			}
			// Otherwise, copy the cell down by the number of gaps below it
			else if (gapsBelow > 0)
			{
				// Move the cell down
				contents[row - gapsBelow][col] = contents[row][col];
				
				// Clear the old location
				contents[row][col] = 0;
			}
		}
	}
	
	[self didChangeValueForKey:@"contents"];
}

- (void)randomShiftRows
{	
	// Iterate over each row of the board
	NSInteger randomNumber, shiftAmount;
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		// Doing this GTetrinet-style: pick a random number in [0, 22)
		randomNumber = random() % 22;
		
		// Use the random value to pick a shift amount
		if (randomNumber < 1)
			shiftAmount = 3;
		else if (randomNumber < 4)
			shiftAmount = 2;
		else if (randomNumber < 11)
			shiftAmount = 1;
		else
			continue; // No shift
		
		[self shiftRow:row
			  byAmount:shiftAmount
		   inDirection:(random() % 2)];
	}
}

- (void)shiftRow:(NSInteger)row
		byAmount:(NSInteger)shiftAmount
     inDirection:(BOOL)shiftLeft
{
	NSInteger col;
	
	[self willChangeValueForKey:@"contents"];
	
	if (shiftLeft)
	{	
		// Shift cells in the row to the left
		for (col = 0; col < (ITET_FIELD_WIDTH - shiftAmount); col++)
			contents[row][col] = contents[row][col + shiftAmount];
		
		// Clear the cells to the right of the shifted columns
		for (; col < ITET_FIELD_WIDTH; col++)
			contents[row][col] = 0;
	}
	else
	{
		// Shift cells in the row to the right
		for (col = ((ITET_FIELD_WIDTH - 1) - shiftAmount); col >= 0; col--)
			contents[row][col + shiftAmount] = contents[row][col];
		
		// Clear the cells to the left
		for (col = 0; col < shiftAmount; col++)
			contents[row][col] = 0;
	}
	
	[self didChangeValueForKey:@"contents"];
}

- (void)explodeBlockBombs
{
	NSMutableArray* scatteredCells = [NSMutableArray array];
	
	[self willChangeValueForKey:@"contents"];
	
	// Scan the board for block bomb specials
	NSInteger row, col;
	uint8_t cell;
	for (row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// If this cell is a block bomb, remove it, and the cells around it
			if (contents[row][col] == blockBomb)
			{
				// Remove the block bomb
				contents[row][col] = 0;
				
				// Check the surrounding cells
				for (NSInteger rowOffset = -1; rowOffset <= 1; rowOffset++)
				{
					for (NSInteger colOffset = -1; colOffset <= 1; colOffset++)
					{
						// Check if this cell is off-field
						if (((row + rowOffset) < 0) || ((row + rowOffset) >= ITET_FIELD_HEIGHT) ||
						    ((col + colOffset) < 0) || ((col + colOffset) >= ITET_FIELD_WIDTH))
							continue;
						
						// Get the contents of each (on-field) cell around the block bomb
						cell = contents[row + rowOffset][col + colOffset];
						
						// Treat other block bomb cells as already empty
						if (cell == blockBomb)
							cell = 0;
						// Clear all other cells
						else
							contents[row + rowOffset][col + colOffset] = 0;
						
						// Collect the cells, to be scattered around the field
						[scatteredCells addObject:[NSNumber numberWithUnsignedChar:cell]];
					}
				}
			}
		}
	}
	
	// Scatter the collected cells around the field, keeping the top six rows clear
	// note: this is GTetrinet's implemetation; some cells may overwrite others
	for (NSNumber* movedCell in scatteredCells)
	{
		row = random() % (ITET_FIELD_HEIGHT - 6);
		col = random() % ITET_FIELD_WIDTH;
		contents[row][col] = [movedCell unsignedCharValue];
	}
	
	[self didChangeValueForKey:@"contents"];
}

#pragma mark -
#pragma mark Accessors

- (uint8_t)cellAtRow:(NSInteger)row
			  column:(NSInteger)col
{
	return contents[row][col];
}

- (NSString*)fieldstring
{
	NSMutableString* field = [NSMutableString stringWithCapacity:(ITET_FIELD_WIDTH * ITET_FIELD_HEIGHT)];
	
	uint8_t cell;
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

char cellToPartialUpdateChar(uint8_t cellType)
{
	// Check if this cell is a special
	uint8_t cellAsSpecial = [iTetSpecials numberForSpecialType:(iTetSpecialType)cellType];
	
	// If it is, index from ASCII 38 ('&')
	if (cellAsSpecial != invalidSpecial)
		return (cellAsSpecial + 38);
	
	// Normal cells are indexed from ASCII 33 ('!')
	return (cellType + 33);
}

uint8_t partialUpdateCharToCell(char updateChar)
{
	// Check to see if the update character maps to a special type
	uint8_t cellAsSpecial = [iTetSpecials specialTypeForNumber:(updateChar - 38)];
	if (cellAsSpecial != invalidSpecial)
		return cellAsSpecial;
	
	// Otherwise, reverse-index from ASCII 33 to get the normal cell type
	return (updateChar - 33);
}

@synthesize lastPartialUpdate;

@end
