//
//  iTetField.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetField.h"
#import "iTetBlock.h"

#define ITET_PARTIAL_UPDATE_CELL_ZERO_INDEX	33

// For the partial update string, rows and columns are reverse-indexed from '3' (decimal 51)...
#define ITET_CONVERT_PARTIAL_ROW(coord)			(((ITET_FIELD_HEIGHT - 1) - (coord)) + '3') // (conveniently, this is its own inverse)
#define ITET_CONVERT_PARTIAL_TO_COL(coord)		((coord) - '3')
#define ITET_CONVERT_PARTIAL_FROM_COL(coord)	((coord) + '3')
// ...and the cell contents are mapped to different characters
char cellToPartialUpdateChar(uint8_t cellType);
uint8_t partialUpdateCharToCell(char updateChar);

const IPSRegion iTetUnknownDirtyRegion = {ITET_FIELD_HEIGHT, ITET_FIELD_WIDTH, -1, -1};
const IPSRegion iTetFullFieldDirtyRegion = {0, 0, (ITET_FIELD_HEIGHT - 1), (ITET_FIELD_WIDTH - 1)};

NSString* const iTetEmptyFieldstringPlaceholder =		@"iTetEmptyFieldstring";
NSString* const iTetUnchangedFieldstringPlaceholder =	@"iTetUnchangedFieldstring";

@interface iTetField (Private)

- (void)shiftRow:(NSInteger)row
		byAmount:(NSInteger)shiftAmount
     inDirection:(BOOL)shiftLeft;

- (FIELD*)contents;
- (NSString*)fullFieldstring;

- (void)setUpdateFieldstring:(NSString*)fieldstring;
- (void)setUpdateDirtyRegion:(IPSRegion)dirtyRegion;

@end

@implementation iTetField

+ (id)field
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	updateFieldstring = iTetEmptyFieldstringPlaceholder;
	updateDirtyRegion = iTetFullFieldDirtyRegion;
	
	return self;
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
	NSUInteger length = [fieldstring lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
	
	// Iterate through the fieldstring
	for (NSUInteger i = 0; i < length; i++)
	{
		// Get the cell value at this index
		char currentChar = field[i];
		uint8_t currentCell;
		
		// If the current cell is a numeric value, convert to its integer value
		if (isdigit(currentChar))
			currentCell = currentChar - '0';
		// Otherwise, just cast
		else
			currentCell = (uint8_t)currentChar;
		
		// Find the coordinates this index corresponds to
		NSInteger row = ((ITET_FIELD_HEIGHT - 1) - (i / ITET_FIELD_WIDTH));
		NSInteger col = (i % ITET_FIELD_WIDTH);
		
		// Set the cell at those coordinates to the value at this index
		contents[row][col] = currentCell;
	}
	
	updateFieldstring = [fieldstring retain];
	updateDirtyRegion = iTetFullFieldDirtyRegion;
	
	return self;
}

+ (id)fieldByApplyingPartialUpdate:(NSString*)partialUpdate
						   toField:(iTetField*)field
{
	return [[[self alloc] initWithPartialUpdate:partialUpdate
										toField:field] autorelease];
}

- (id)initWithPartialUpdate:(NSString*)partialUpdate
					toField:(iTetField*)field
{
	// Copy the existing field
	[self initWithField:field];
	updateDirtyRegion = iTetUnknownDirtyRegion;
	
	// Apply the partial update
	// Convert the update string to ASCII
	const char* update = [partialUpdate cStringUsingEncoding:NSASCIIStringEncoding];
	NSUInteger length = [partialUpdate lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
	
	// Get the first type of cell we are adding
	char currentChar = update[0];
	uint8_t cellType = partialUpdateCharToCell(currentChar);
	
	// For each coordinate pair in the fieldstring
	for (NSUInteger i = 1; i < length; i++)
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
			// Convert the coordinates to our coordinate system
			NSInteger col = ITET_CONVERT_PARTIAL_TO_COL(update[i]);
			NSInteger row = ITET_CONVERT_PARTIAL_ROW(update[i+1]);
			
			// Change the cell on the field to the current type
			contents[row][col] = cellType;
			
			// Skip the next character (we just used it)
			i++;
			
			// Keep track of the bounds of the region of the field that will need to be redrawn
			updateDirtyRegion.minRow = MIN(updateDirtyRegion.minRow, row);
			updateDirtyRegion.minCol = MIN(updateDirtyRegion.minCol, col);
			updateDirtyRegion.maxRow = MAX(updateDirtyRegion.maxRow, row);
			updateDirtyRegion.maxCol = MAX(updateDirtyRegion.maxCol, col);
		}
	}
	
	updateFieldstring = [partialUpdate copy];
}

#pragma mark Fields with Starting Stack

+ (id)fieldWithStackHeight:(NSInteger)stackHeight
{
	return [[[self alloc] initWithStackHeight:stackHeight] autorelease];
}

- (id)initWithStackHeight:(NSInteger)stackHeight
{	
	// For each row of the starting stack, fill with debris
	// Uses GTetrinet's method; bizarre, but whatever
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
	
	updateFieldstring = [[self fullFieldstring] retain];
	updateDirtyRegion = iTetFullFieldDirtyRegion;
	
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
	
	updateFieldstring = [[self fullFieldstring] retain];
	updateDirtyRegion = iTetFullFieldDirtyRegion;
	
	return self;
}

#pragma mark Copying Fields

- (id)copyWithZone:(NSZone*)zone
{
	return [[[self class] allocWithZone:zone] initWithField:self];
}

+ (id)fieldWithField:(iTetField*)field
{
	return [[[self alloc] initWithField:field] autorelease];
}

- (id)initWithField:(iTetField*)field
{	
	memcpy(contents, *[field contents], (ITET_FIELD_HEIGHT * ITET_FIELD_WIDTH * sizeof(uint8_t)));
	
	updateFieldstring = iTetUnchangedFieldstringPlaceholder;
	updateDirtyRegion = IPSEmptyRegion;
	
	return self;
}

- (void)dealloc
{
	[updateFieldstring release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Obstruction Testing

- (iTetObstructionState)blockObstructed:(iTetBlock*)block
{
	iTetObstructionState side = obstructNone;
	
	// For each cell in the block, check if it is obstructed on the field
	for (NSInteger row = 0; row < ITET_BLOCK_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_BLOCK_WIDTH; col++)
		{
			uint8_t cell = [block cellAtRow:row
									 column:col];
			if (cell != 0)
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
#pragma mark Field Changes/Updates

- (iTetField*)fieldBySolidifyingBlock:(iTetBlock*)block
{
	iTetField* newField = [iTetField fieldWithField:self];
	FIELD* newContents = [newField contents];
	
	NSMutableString* fieldstring = [NSMutableString string];
	IPSRegion dirtyRegion = iTetUnknownDirtyRegion;
	
	uint8_t lastCell = 0;
	for (NSInteger blockRow = 0; blockRow < ITET_BLOCK_HEIGHT; blockRow++)
	{
		for (NSInteger blockCol = 0; blockCol < ITET_BLOCK_WIDTH; blockCol++)
		{
			uint8_t cell = [block cellAtRow:blockRow
									 column:blockCol];
			if (cell != 0)
			{
				// Determine the coordinates of the field at which to add the cell
				NSInteger fieldRow = ([block rowPos] + blockRow), fieldCol = ([block colPos] + blockCol);
				
				// Add this cell of the block to the field
				(*newContents)[fieldRow][fieldCol] = cell;
				
				// If this cell is a different "color" from the last one in the partial update, add that information to the update string
				if (cell != lastCell)
				{
					[fieldstring appendFormat:@"%c", cellToPartialUpdateChar(cell)];
					lastCell = cell;
				}
				
				// Append the changed cell's field coordinates to the partial update
				[fieldstring appendFormat:@"%c%c", ITET_CONVERT_PARTIAL_FROM_COL(fieldCol), ITET_CONVERT_PARTIAL_ROW(fieldRow)];
				
				// Keep track of the bounds of the region of the field that will need to be redrawn
				dirtyRegion.minRow = MIN(dirtyRegion.minRow, fieldRow);
				dirtyRegion.minCol = MIN(dirtyRegion.minCol, fieldCol);
				dirtyRegion.maxRow = MAX(dirtyRegion.maxRow, fieldRow);
				dirtyRegion.maxCol = MAX(dirtyRegion.maxCol, fieldCol);
			}
		}
	}
	
	[newField setUpdateFieldstring:fieldstring];
	[newField setUpdateDirtyRegion:dirtyRegion];
	
	return newField;
}

- (iTetField*)fieldWithLinesCleared:(NSInteger*)linesCleared
				  retrievedSpecials:(NSArray**)specialsRetrieved
{
	iTetField* newField = [iTetField field];
	FIELD* newContents = [newField contents];
	
	NSInteger lines = 0;
	
	NSMutableArray* specials = nil;
	if (specialsRetrieved != NULL)
	{
		specials = [NSMutableArray array];
		*specialsRetrieved = specials;
	}
	
	// Scan the old field for complete lines, bottom-to-top
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		NSInteger col;
		for (col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			if (contents[row][col] == 0)
				break;
		}
		
		// If all cells in this row are filled...
		if (col == ITET_FIELD_WIDTH)
		{
			// ...increment the number of cleared lines...
			lines++;
			
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
		// Otherwise, copy the line to the new field, moving it down by the number of lines cleared below it
		else
		{
			memcpy((*newContents)[row - lines], contents[row], sizeof(contents[row]));
		}
	}
	
	// Minor optimization: if no lines were cleared, carry over the field-update deltas from the old field
	if (lines == 0)
	{
		[newField setUpdateFieldstring:[self updateFieldstring]];
		[newField setUpdateDirtyRegion:[self updateDirtyRegion]];
	}
	else
	{
		// Otherwise, make sure they get calculated later
		[newField setUpdateFieldstring:nil];
		[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	}
	
	// Return (through the provided pointer) the number of lines cleared
	if (linesCleared != NULL)
		*linesCleared = lines;
	
	return newField;
}

- (iTetField*)fieldWithLinesCleared
{
	return [self fieldWithLinesCleared:NULL
					 retrievedSpecials:NULL];
}

- (iTetField*)fieldByAddingSpecials:(NSInteger)count
				   usingFrequencies:(NSArray*)specialFrequencies
{
	NSParameterAssert(specialFrequencies != nil);
	NSParameterAssert([specialFrequencies count] == 100);
	
	iTetField* newField = [iTetField fieldWithField:self];
	[newField setUpdateFieldstring:nil];
	[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	FIELD* newContents = [newField contents];
	
	if (count == 0)
		return newField;
	
	// Count the number of non-special filled cells on the old field
	NSInteger numNonSpecialCells = 0;
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			uint8_t cell = contents[row][col];
			if ((cell > 0) && (cell <= ITET_NUM_CELL_COLORS))
				numNonSpecialCells++;
		}
	}
	
	// Attempt to add the specified number of specials
	for (NSInteger specialsAdded = 0; specialsAdded < count; specialsAdded++)
	{
		// If there are non-special cells on the field, replace one at random with a special
		if (numNonSpecialCells > 0)
		{
			// Choose a random number of cells to pass over before dropping the special
			NSInteger cellsLeftToSkip = random() % numNonSpecialCells;
			
			// Iterate over the field
			for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
			{
				for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
				{
					// If this is a non-special cell, check whether to add the special
					uint8_t cell = (*newContents)[row][col];
					if ((cell > 0) && (cell <= ITET_NUM_CELL_COLORS))
					{
						// If we have skipped the predetermined number of cells, add the special
						if (cellsLeftToSkip == 0)
						{
							// Replace the cell with a random special
							(*newContents)[row][col] = [[specialFrequencies objectAtIndex:(random() % [specialFrequencies count])] unsignedCharValue];
							
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
				NSInteger col = random() % ITET_FIELD_WIDTH;
				
				// Check if the column is empty
				NSInteger row;
				for (row = 0; row < ITET_FIELD_HEIGHT; row++)
				{
					if ((*newContents)[row][col] > 0)
						break;
				}
				
				// If the column was empty, add the new special
				if (row == ITET_FIELD_HEIGHT)
				{
					// Add the new special to the bottom row
					(*newContents)[0][col] = [[specialFrequencies objectAtIndex:(random() % [specialFrequencies count])] unsignedCharValue];
					
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
	
	return newField;
}

#pragma mark Specials

- (iTetField*)fieldByAddingLines:(NSInteger)numLines
						   style:(iTetLineAddStyle)style
					  playerLost:(BOOL*)playerLost
{
	NSParameterAssert(playerLost != NULL);
	
	iTetField* newField = [iTetField field];
	FIELD* newContents = [newField contents];
	
	*playerLost = NO;
	
	// Check if adding the specified number of lines will cause the field to "overflow" (and the player to lose)
	for (NSInteger row = (ITET_FIELD_HEIGHT - 1); (row >= (ITET_FIELD_HEIGHT - numLines)) && !(*playerLost); row--)
	{
		for (NSInteger col = 0;  (col < ITET_FIELD_WIDTH) && !(*playerLost); col++)
		{
			// If any cell in one of these rows is filled, the field will overflow when the specified number of lines is added
			if (contents[row][col] > 0)
				*playerLost = YES;
		}
	}
	
	// Copy rows from the old field to the new, shifting up by the appropriate number of lines
	for (NSInteger row = 0; row < (ITET_FIELD_HEIGHT - numLines); row++)
	{
		memcpy((*newContents)[row + numLines], contents[row], sizeof(contents[row]));
	}
	
	// Fill the empty rows at the bottom of the new field with garbage
	for (NSInteger row = 0; row < numLines; row++)
	{
		// Determine what style of line add to perform
		if (style == classicStyle)
		{
			// Fill the bottom row completely
			for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
				(*newContents)[0][col] = (random() % ITET_NUM_CELL_COLORS) + 1;
			
			// Clear a random cell in the row
			(*newContents)[0][(random() % ITET_FIELD_WIDTH)] = 0;
		}
		else
		{
			// Fill the bottom row randomly
			for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
				(*newContents)[0][col] = random() % (ITET_NUM_CELL_COLORS + 1);
			
			// Ensure that at least one column index is empty
			(*newContents)[0][(random() % ITET_FIELD_WIDTH)] = 0;
		}
	}
	
	// Make sure the field-update deltas get calculated later
	[newField setUpdateFieldstring:nil];
	[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	
	return newField;
}

- (iTetField*)fieldByClearingBottomLine
{
	iTetField* newField = [iTetField field];
	FIELD* newContents = [newField contents];
	
	// Copy all lines (except the bottom) from the old field to the new, shifting down by one row
	for (NSInteger row = 1; row < ITET_FIELD_HEIGHT; row++)
	{
		memcpy((*newContents)[row - 1], contents[row], sizeof(contents[row]));
	}
	
	// Make sure the field-update deltas get calculated later
	[newField setUpdateFieldstring:nil];
	[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	
	return newField;
}

#define ITET_NUM_RANDOM_CLEARS	(10)

- (iTetField*)fieldByClearingTenRandomCells
{
	iTetField* newField = [iTetField fieldWithField:self];
	FIELD* newContents = [newField contents];
	
	NSMutableString* updatedCoordinates = [NSMutableString string];
	IPSRegion dirtyRegion = iTetUnknownDirtyRegion;
	
	// Clear ten random cells on the field
	for (NSInteger cellsCleared = 0; cellsCleared < ITET_NUM_RANDOM_CLEARS; cellsCleared++)
	{
		// Select random row/column indexes
		NSInteger row = (random() % ITET_FIELD_HEIGHT), col = (random() % ITET_FIELD_WIDTH);
		
		// Check if the cell is already empty
		if ((*newContents)[row][col] != 0)
		{
			// Clear the cell
			(*newContents)[row][col] = 0;
			
			// Append the coordinates to the partial-update fieldstring
			[updatedCoordinates appendFormat:@"%c%c", ITET_CONVERT_PARTIAL_FROM_COL(col), ITET_CONVERT_PARTIAL_ROW(row)];
			
			// Keep track of the bounds of the region of the field that will need to be redrawn
			dirtyRegion.minRow = MIN(dirtyRegion.minRow, row);
			dirtyRegion.minCol = MIN(dirtyRegion.minCol, col);
			dirtyRegion.maxRow = MAX(dirtyRegion.maxRow, row);
			dirtyRegion.maxCol = MAX(dirtyRegion.maxCol, col);
		}
	}
	
	// Check if the field has changed at all (this special sometimes has no effect)
	if ([updatedCoordinates length] > 0)
	{
		[newField setUpdateFieldstring:[NSString stringWithFormat:@"%c%@", cellToPartialUpdateChar(0), updatedCoordinates]];
		[newField setUpdateDirtyRegion:dirtyRegion];
	}
	
	return newField;
}

#define ITET_NUM_CLEAR_ROWS	(6)

- (iTetField*)fieldByClearingTopSixRows
{
	// Find the highest row among the top six with an occupied cell
	NSInteger rowsToShift = 0;
	for (NSInteger row = (ITET_FIELD_HEIGHT - 1); row > ((ITET_FIELD_HEIGHT - 1) - ITET_NUM_CLEAR_ROWS); row--)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			if (contents[row][col] > 0)
			{
				rowsToShift = row - ((ITET_FIELD_HEIGHT - 1) - ITET_NUM_CLEAR_ROWS);
				goto cellfound;
			}
		}
	}
cellfound:
	
	// Return a copy of the field, shifted down by the appropriate amount
	return [self fieldByShiftingContentsDownByAmount:rowsToShift];
}

- (iTetField*)fieldByShiftingContentsDownByAmount:(NSInteger)shiftAmount
{
	if (shiftAmount <= 0)
		return [iTetField fieldWithField:self];
	
	iTetField* newField = [iTetField field];
	FIELD* newContents = [newField contents];
	
	// Iterate over rows on the old field, skipping rows at the bottom, and any clear rows at the top, and copy them to the new field, shifted down
	for (NSInteger row = shiftAmount; row < (ITET_FIELD_HEIGHT - (ITET_NUM_CLEAR_ROWS - shiftAmount)); row++)
	{
		memcpy((*newContents)[row - shiftAmount], contents[row], sizeof(contents[row]));
	}
	
	// Make sure the field-update deltas get calculated later
	[newField setUpdateFieldstring:nil];
	[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	
	return newField;
}

- (iTetField*)fieldByRemovingAllSpecials
{
	iTetField* newField = [iTetField fieldWithField:self];
	FIELD* newContents = [newField contents];
	
	// Iterate over the old field
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// Check if each cell is a special on the old field
			if (contents[row][col] > ITET_NUM_CELL_COLORS)
			{
				// Change the special to a random normal cell
				(*newContents)[row][col] = ((random() % ITET_NUM_CELL_COLORS) + 1);
			}
		}
	}
	
	[newField setUpdateFieldstring:nil];
	[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	
	return newField;
}

- (iTetField*)fieldByPullingCellsDown
{
	iTetField* newField = [iTetField field];
	FIELD* newContents = [newField contents];
	
	// Iterate over the field in column-row order (my apologies to the CPU cache)
	for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
	{
		// Scan the column for gaps, bottom-to-top
		NSInteger gapsBelow = 0;
		for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
		{
			// If the cell is empty, increment the number of gaps in the column
			if (contents[row][col] == 0)
			{
				gapsBelow++;
			}
			// Otherwise, copy the cell to the new field, shifted down by the number of gaps below it
			else
			{
				(*newContents)[row - gapsBelow][col] = contents[row][col];
			}
		}
	}
	
	// Make sure the field-update deltas get calculated later
	[newField setUpdateFieldstring:nil];
	[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	
	return newField;
}

- (iTetField*)fieldByRandomlyShiftingRows
{
	iTetField* newField = [iTetField field];
	FIELD* newContents = [newField contents];
	
	// Iterate over each row of the old field
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		// Doing this GTetrinet-style: pick a random number in [0, 22)
		NSInteger randomNumber = random() % 22, shiftAmount = 0;
		
		// Use the random value to pick a shift amount
		if (randomNumber < 1)
			shiftAmount = 3;
		else if (randomNumber < 4)
			shiftAmount = 2;
		else if (randomNumber < 11)
			shiftAmount = 1;
		else
			shiftAmount = 0; // No shift
		
		// Pick a shift direction
		BOOL shiftLeft = (random() % 2);
		if (shiftLeft)
		{
			// Copy the row from the old field to the new, shifted left by the chosen amount
			memcpy((*newContents)[row], (contents[row] + shiftAmount), (sizeof(uint8_t) * (ITET_FIELD_WIDTH - shiftAmount)));
		}
		else
		{
			// Copy the row from the old field to the new, shifted right by the chosen amount
			memcpy(((*newContents)[row] + shiftAmount), contents[row], (sizeof(uint8_t) * (ITET_FIELD_WIDTH - shiftAmount)));
		}
	}
	
	// Make sure the field-update deltas get calculated later
	[newField setUpdateFieldstring:nil];
	[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	
	return newField;
}

- (iTetField*)fieldByExplodingBlockBombs
{
	iTetField* newField = [iTetField fieldWithField:self];
	FIELD* newContents = [newField contents];
	
	NSMutableArray* scatteredCells = [NSMutableArray array];
	
	// Scan the field for block bomb specials
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// If this cell is a block bomb on the old field, remove it from the new field
			if (contents[row][col] == blockBomb)
			{
				// Remove the block bomb
				(*newContents)[row][col] = 0;
				
				// Clear the surrounding cells, and collect their contents, to be "scattered" around the field
				for (NSInteger rowOffset = -1; rowOffset <= 1; rowOffset++)
				{
					for (NSInteger colOffset = -1; colOffset <= 1; colOffset++)
					{
						// Check if this cell is off-field
						if (((row + rowOffset) < 0) || ((row + rowOffset) >= ITET_FIELD_HEIGHT) ||
							((col + colOffset) < 0) || ((col + colOffset) >= ITET_FIELD_WIDTH))
							continue;
						
						// Get the contents of each (on-field) cell around the block bomb
						uint8_t cell = (*newContents)[row + rowOffset][col + colOffset];
						
						// Ignore other block bomb cells found in this way
						if (cell != blockBomb)
						{
							(*newContents)[row + rowOffset][col + colOffset] = 0;
							
							// Collect the cells, to be scattered around the field
							[scatteredCells addObject:[NSNumber numberWithUnsignedChar:cell]];
						}
					}
				}
			}
		}
	}
	
	// Scatter the collected cells around the field (leaving the top six rows clear)
	// note: this is GTetrinet's implemetation; some cells may overwrite others
	for (NSNumber* movedCell in scatteredCells)
	{
		(*newContents)[(random() % (ITET_FIELD_HEIGHT - ITET_NUM_CLEAR_ROWS))][(random() % ITET_FIELD_WIDTH)] = [movedCell unsignedCharValue];
	}
	
	// Make sure the field-update deltas get calculated later
	[newField setUpdateFieldstring:nil];
	[newField setUpdateDirtyRegion:iTetUnknownDirtyRegion];
	
	return newField;
}

#pragma mark -
#pragma mark Accessors

// Total cell types = |{empty cell}| + |{normal cells}| + |{specials}|
#define ITET_TOTAL_CELL_TYPES	(1 + (ITET_NUM_CELL_COLORS) + (ITET_NUM_SPECIAL_TYPES))

- (void)setUpdateDeltasFromField:(iTetField*)field
{
	NSInteger totalCellsChanged = 0;
	
	IPSCoord updateCoordinates[ITET_TOTAL_CELL_TYPES][ITET_FIELD_WIDTH * ITET_FIELD_HEIGHT];
	memset(&updateCoordinates, 0, sizeof(updateCoordinates));
	
	NSInteger cellTypeUpdateCount[ITET_TOTAL_CELL_TYPES];
	memset(&cellTypeUpdateCount, 0, sizeof(cellTypeUpdateCount));
	
	IPSRegion dirtyRegion = iTetUnknownDirtyRegion;
	
	// Iterate over the fields
	FIELD* otherContents = [field contents];
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// Check if the cell at these coordinates differs from the same cell on the other field
			uint8_t cell = contents[row][col];
			if (cell != (*otherContents)[row][col])
			{
				// Convert the cell value to an index in the array of updated coordinates
				NSInteger cellTypeIndex = (cellToPartialUpdateChar(cell) - ITET_PARTIAL_UPDATE_CELL_ZERO_INDEX);
				
				// Add the current coordinates to the list of changed coordinates for cells of this type
				updateCoordinates[cellTypeIndex][cellTypeUpdateCount[cellTypeIndex]] = IPSMakeCoord(row, col);
				
				// Increment the count of cells in the delta, along with the count of cells of this type
				cellTypeUpdateCount[cellTypeIndex]++;
				totalCellsChanged++;
				
				// Keep track of the bounds of the region of the field that will need to be redrawn
				dirtyRegion.minRow = MIN(dirtyRegion.minRow, row);
				dirtyRegion.minCol = MIN(dirtyRegion.minCol, col);
				dirtyRegion.maxRow = MAX(dirtyRegion.maxRow, row);
				dirtyRegion.maxCol = MAX(dirtyRegion.maxCol, col);
			}
		}
	}
	
	// Short-circuit optimization: check if the fields are identical
	if (totalCellsChanged <= 0)
	{
		[self setUpdateFieldstring:iTetUnchangedFieldstringPlaceholder];
		[self setUpdateDirtyRegion:IPSEmptyRegion];
		return;
	}
	
	// Count the number of cell type which have update coordinates on the field
	NSInteger cellTypesWithChanges = 0;
	for (NSInteger cellTypeIndex = 0; cellTypeIndex < ITET_TOTAL_CELL_TYPES; cellTypeIndex++)
	{
		if (cellTypeUpdateCount[cellTypeIndex] > 0)
			cellTypesWithChanges++;
	}
	
	// Short-circuit optimization: check if a partial-update fieldstring would be longer than a standard, full-field fieldstring
	// Length = (one character for each cell type with updates) + (two characters for row/column indexes of each updated cell)
	NSInteger partialUpdateLength = (cellTypesWithChanges + (totalCellsChanged * 2));
	if (partialUpdateLength >= (ITET_FIELD_WIDTH * ITET_FIELD_HEIGHT))
	{
		[self setUpdateFieldstring:[self fullFieldstring]];
		
		// Keep the calculated dirty region; it may still be smaller than the whole field
		[self setUpdateDirtyRegion:dirtyRegion];
		
		return;
	}
	
	// Create the partial update fieldstring
	NSMutableString* partialUpdate = [NSMutableString stringWithCapacity:partialUpdateLength];
	for (NSInteger cellTypeIndex = 0; cellTypeIndex < ITET_TOTAL_CELL_TYPES; cellTypeIndex++)
	{
		if (cellTypeUpdateCount[cellTypeIndex] <= 0)
			continue;
		
		// Append the specifier character for this cell-type to the update string
		[partialUpdate appendFormat:@"%c", (cellTypeIndex + ITET_PARTIAL_UPDATE_CELL_ZERO_INDEX)];
		
		// For each updated coordinate of this cell type...
		for (NSInteger coordinateIndex = 0; coordinateIndex < cellTypeUpdateCount[cellTypeIndex]; coordinateIndex++)
		{
			// Convert to the partial-update format, and append in column-row order
			IPSCoord coord = updateCoordinates[cellTypeIndex][coordinateIndex];
			[partialUpdate appendFormat:@"%c%c", ITET_CONVERT_PARTIAL_FROM_COL(coord.col), ITET_CONVERT_PARTIAL_ROW(coord.row)];
		}
	}
	
	[self setUpdateFieldstring:partialUpdate];
	[self setUpdateDirtyRegion:dirtyRegion];
}

- (void)setUpdateDirtyRegionFromField:(iTetField*)field
{
	IPSRegion dirtyRegion = iTetUnknownDirtyRegion;
	
	// Iterate over the fields
	FIELD* otherContents = [field contents];
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// Check if the cell at these coordinates differs from the same cell on the other field
			uint8_t cell = contents[row][col];
			if (cell != (*otherContents)[row][col])
			{
				// Keep track of the bounds of the region of the field that will need to be redrawn
				dirtyRegion.minRow = MIN(dirtyRegion.minRow, row);
				dirtyRegion.minCol = MIN(dirtyRegion.minCol, col);
				dirtyRegion.maxRow = MAX(dirtyRegion.maxRow, row);
				dirtyRegion.maxCol = MAX(dirtyRegion.maxCol, col);
			}
		}
	}
	
	// Check if the fields are identical
	if (IPSEqualRegions(dirtyRegion, iTetUnknownDirtyRegion))
		[self setUpdateDirtyRegion:IPSEmptyRegion];
	else
		[self setUpdateDirtyRegion:dirtyRegion];
}

- (FIELD*)contents
{
	return &contents;
}

- (uint8_t)cellAtRow:(NSInteger)row
			  column:(NSInteger)col
{
	return contents[row][col];
}

- (NSString*)fullFieldstring
{
	NSMutableString* fieldstring = [NSMutableString stringWithCapacity:(ITET_FIELD_WIDTH * ITET_FIELD_HEIGHT)];
	
	// Iterate over the whole field (TOP TO BOTTOM)
	for (NSInteger row = (ITET_FIELD_HEIGHT - 1); row >= 0; row--)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// Get the contents of this cell
			uint8_t cell = contents[row][col];
			
			// If the cell contains a special, add the special's letter to the fieldstring
			if (cell > ITET_NUM_CELL_COLORS)
				[fieldstring appendFormat:@"%c", cell];
			// Otherwise, add the cell's numeric value
			else
				[fieldstring appendFormat:@"%d", cell];
		}
	}
	
	// Return the completed fieldstring
	return fieldstring;
}

- (void)setUpdateFieldstring:(NSString*)fieldstring
{
	NSString* temp = [fieldstring copy];
	[updateFieldstring release];
	updateFieldstring = temp;
}
@synthesize updateFieldstring;

- (void)setUpdateDirtyRegion:(IPSRegion)dirtyRegion
{
	updateDirtyRegion = dirtyRegion;
}
@synthesize updateDirtyRegion;

@end

char cellToPartialUpdateChar(uint8_t cellType)
{
	// Check if this cell is a special
	uint8_t cellAsSpecial = [iTetSpecials numberForSpecialType:(iTetSpecialType)cellType];
	
	// If it is, index from ASCII 38 ('&')
	if (cellAsSpecial != invalidSpecial)
		return (cellAsSpecial + (ITET_PARTIAL_UPDATE_CELL_ZERO_INDEX + ITET_NUM_CELL_COLORS));
	
	// Normal cells are indexed from ASCII 33 ('!')
	return (cellType + ITET_PARTIAL_UPDATE_CELL_ZERO_INDEX);
}

uint8_t partialUpdateCharToCell(char updateChar)
{
	// Check to see if the update character maps to a special type
	uint8_t cellAsSpecial = [iTetSpecials specialTypeForNumber:(updateChar - (ITET_PARTIAL_UPDATE_CELL_ZERO_INDEX + ITET_NUM_CELL_COLORS))];
	if (cellAsSpecial != invalidSpecial)
		return cellAsSpecial;
	
	// Otherwise, reverse-index from ASCII 33 to get the normal cell type
	return (updateChar - ITET_PARTIAL_UPDATE_CELL_ZERO_INDEX);
}
