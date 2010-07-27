//
//  iTetField.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetSpecials.h"
#import "IPSIntegerGeometry.h"

#define ITET_FIELD_WIDTH	12
#define ITET_FIELD_HEIGHT	22

typedef uint8_t FIELD[ITET_FIELD_HEIGHT][ITET_FIELD_WIDTH];

typedef enum
{
	obstructNone =	0,
	obstructVert =	1,
	obstructHoriz =	2
} iTetObstructionState;

typedef enum
{
	specialStyle,
	classicStyle
} iTetLineAddStyle;

extern const IPSRegion iTetUnknownDirtyRegion;
extern const IPSRegion iTetFullFieldDirtyRegion;

extern NSString* const iTetEmptyFieldstringPlaceholder;
extern NSString* const iTetUnchangedFieldstringPlaceholder;

@class iTetBlock;

@interface iTetField: NSObject <NSCopying>
{
	// Contents of the field, indexed row/column, bottom-to-top, left-to-right
	FIELD contents;
	
	// Field-update deltas
	NSString* updateFieldstring;
	IPSRegion updateDirtyRegion;
}

// Initializer for an empty field
+ (id)field;

// Initializer from a full-field fieldstring
+ (id)fieldFromFieldstring:(NSString*)fieldstring;
- (id)initWithFieldstring:(NSString*)fieldstring;

// Initializer from an existing field and a partial update
+ (id)fieldByApplyingPartialUpdate:(NSString*)partialUpdate
						   toField:(iTetField*)field;
- (id)initWithPartialUpdate:(NSString*)partialUpdate
					toField:(iTetField*)field;

// Initializers for a field with a starting stack height
+ (id)fieldWithStackHeight:(NSInteger)stackHeight;
- (id)initWithStackHeight:(NSInteger)stackHeight;

// Initializers for a random field
+ (id)fieldWithRandomContents;
- (id)initWithRandomContents;

// Copy initializer
+ (id)fieldWithField:(iTetField*)field;
- (id)initWithField:(iTetField*)field;

// Checks whether a block is in a valid position on the field
- (iTetObstructionState)blockObstructed:(iTetBlock*)block;

// Checks whether the specified cell is valid (i.e., on the field) and empty
- (iTetObstructionState)cellObstructedAtRow:(NSInteger)row
									 column:(NSInteger)col;

// Returns a new field created by adding the cells of the specified block to the receiver's contents
- (iTetField*)fieldBySolidifyingBlock:(iTetBlock*)block;

// Returns a new field by clearing completed lines in the receiver, counting the lines cleared and retreiving any specials from those lines
- (iTetField*)fieldWithLinesCleared:(NSInteger*)linesCleared
				  retrievedSpecials:(NSArray**)specialsRetrieved;

// Returns a new field by clearing completed lines in the receiver, without retrieving specials or counting lines
- (iTetField*)fieldWithLinesCleared;

// Returns a new field with the specified number of specials added to the receiver's contents, using the provided frequencies
// specialFrequencies must be of length 100
- (iTetField*)fieldByAddingSpecials:(NSInteger)count
				   usingFrequencies:(NSArray*)specialFrequencies;

// Returns a new field with the specified number of lines of garbage added to the bottom of the receiver's contents
- (iTetField*)fieldByAddingLines:(NSInteger)numLines
						   style:(iTetLineAddStyle)style
					  playerLost:(BOOL*)playerLost;

// Returns a new field with the bottom line of the receiver's contents removed, shifting others down; does not collect specials
- (iTetField*)fieldByClearingBottomLine;

// Returns a new field with ten random cells from the receiver's contents cleared
- (iTetField*)fieldByClearingTenRandomCells;

// Returns a new field with the top six rows of the receiver's contents cleared; used after a switchfield special to prevent cheap kills
- (iTetField*)fieldByClearingTopSixRows;

// Returns a new field with the contents of the receiver shifted down by the specified number of rows
- (iTetField*)fieldByShiftingContentsDownByAmount:(NSInteger)shiftAmount;

// Returns a new field with all special blocks on in the receiver's contents converted into normal cells
- (iTetField*)fieldByRemovingAllSpecials;

// Returns a new field with all cells in the receiver's contents pulled down to fill gaps
- (iTetField*)fieldByPullingCellsDown;

// Returns a new field with each row in the reciever's contents shifted by 0-3 columns to the left or right at random
- (iTetField*)fieldByRandomlyShiftingRows;

// Returns a new field with all block bomb specials in the receiver's contents "exploded", scattering the cells around them
- (iTetField*)fieldByExplodingBlockBombs;

// Computes and sets the receiver's field-update delta ivars (partial fieldstring and dirty region)
- (void)setUpdateDeltasFromField:(iTetField*)field;

// Computes and sets the receiver's dirty region
- (void)setUpdateDirtyRegionFromField:(iTetField*)field;

// Returns the contents of the cell at the specified coordinates on the field
- (uint8_t)cellAtRow:(NSInteger)row
			  column:(NSInteger)col;

// Returns the partial fieldstring calculated by -setUpdateDeltasFromField:
@property (readonly) NSString* updateFieldstring;

// Returns a region calculated by -setUpdateDeltasFromField:, to be used by fieldviews to determine the portion of the view that needs to be redrawn
@property (readonly) IPSRegion updateDirtyRegion;

@end
