//
//  iTetBlock+Drawing.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetBlock+Drawing.h"
#import "iTetTheme.h"

@implementation iTetBlock (Drawing)

- (NSImage*)imageWithSize:(NSSize)size
			  theme:(iTetTheme*)theme
{
	// Create an NSImage to draw to
	NSImage* image = [[NSImage alloc] initWithSize:
		   NSMakeSize((ITET_BLOCK_WIDTH * ITET_DEF_CELL_WIDTH), (ITET_BLOCK_HEIGHT * ITET_DEF_CELL_HEIGHT))];
	
	// Prepare the image for drawing
	[image lockFocus];
	
	// For each occupied cell of the block, draw the fill for that region
	int row, col;
	char cell;
	NSImage* cellImage;
	for (row = 0; row < ITET_BLOCK_HEIGHT; row++)
	{
		for (col = 0; col < ITET_BLOCK_WIDTH; col++)
		{
			cell = [self cellAtRow:row column:col];
			if (cell)
			{
				cellImage = [theme imageForCellType:cell];
				[cellImage drawAtPoint:NSMakePoint(ITET_DEF_CELL_WIDTH * col, ITET_DEF_CELL_HEIGHT * row)
						  fromRect:NSZeroRect
						 operation:NSCompositeSourceOver
						  fraction:1.0];
			}
		}
	}
	
	// Release drawing focus
	[image unlockFocus];
	
	// Scale the image to fill the specified rectangle
	[image setScalesWhenResized:YES];
	[image setSize:size];
	
	// Return the image
	return [image autorelease];
}

@end
