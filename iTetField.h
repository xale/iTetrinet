//
//  iTetField.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import <Cocoa/Cocoa.h>

#define ITET_FIELD_WIDTH	12
#define ITET_FIELD_HEIGHT	22

typedef enum
{
	obstructNone,
	obstructVert,
	obstructHoriz
} ObstructionState;

@class iTetBlock;

@interface iTetField: NSObject
{
	char contents[ITET_FIELD_HEIGHT][ITET_FIELD_WIDTH];
	
	NSString* lastPartialUpdate;
}

// Initializer for an empty field
+ (id)field;

// Initializers for a field with a starting stack height
+ (id)fieldWithStackHeight:(int)stackHeight;
- (id)initWithStackHeight:(int)stackHeight;

// Initializers for a random field
+ (id)fieldWithRandomContents;
- (id)initWithRandomContents;

// Initializers for copying an existing field
+ (id)fieldWithField:(iTetField*)field;
- (id)initWithField:(iTetField*)field;

// Checks whether a block is in a valid position on the field
- (ObstructionState)blockObstructed:(iTetBlock*)block;

// Checks whether the specified cell is valid (i.e., on the field) and empty
- (ObstructionState)cellObstructedAtRow:(int)row
					   column:(int)col;

// Add the cells of the specified block to the field's contents
- (void)solidifyBlock:(iTetBlock*)block;

// Returns the contents of the specified cell of the field
- (char)cellAtRow:(int)row
	     column:(int)column;

// The current fieldstring that describes the state of the field
@property (readonly) NSString* fieldstring;

// The fieldstring for last partial update
@property (readwrite, retain) NSString* lastPartialUpdate;

@end
