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
	NSSize cellSize = [theme cellSize];
	NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize((cellSize.width * ITET_BLOCK_WIDTH), (cellSize.height * ITET_BLOCK_HEIGHT))];
	
	// Prepare the image for drawing
	[image lockFocus];
	
	// For each occupied cell of the block, draw the fill for that region
	NSInteger row, col;
	char cellType;
	NSImage* cellImage;
	for (row = 0; row < ITET_BLOCK_HEIGHT; row++)
	{
		for (col = 0; col < ITET_BLOCK_WIDTH; col++)
		{
			cellType = [self cellAtRow:row column:col];
			if (cellType > 0)
			{
				cellImage = [theme imageForCellType:cellType];
				[cellImage drawAtPoint:NSMakePoint(cellSize.width * col, cellSize.height * row)
						  fromRect:NSZeroRect
						 operation:NSCompositeSourceOver
						  fraction:1.0];
			}
		}
	}
	
	// Release drawing focus
	[image unlockFocus];
	
	// Resize the image to fill the specified rectangle
	[image setSize:size];
	
	// Return the image
	return [image autorelease];
}

@end
