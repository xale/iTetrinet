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
	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize((cellSize.width * ITET_BLOCK_WIDTH), (cellSize.height * ITET_BLOCK_HEIGHT))] autorelease];
	
	// Prepare the image for drawing
	[image lockFocus];
	
	// For each occupied cell of the block, draw the fill for that region
	NSInteger row, col;
	uint8_t cellType;
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
	return image;
}

static NSRect ITET_I_BLOCK_RECTS[2] = {
	{1, 0, 1, 4},
	{0, 2, 4, 1}
};

static NSRect ITET_O_BLOCK_RECT = {0, 2, 2, 2};

static NSRect ITET_J_BLOCK_RECTS[4] = {
	{0, 1, 2, 3},
	{0, 2, 3, 2},
	{1, 1, 2, 3},
	{0, 1, 3, 2}
};

static NSRect ITET_L_BLOCK_RECTS[4] = {
	{0, 1, 2, 3},
	{0, 2, 3, 2},
	{1, 1, 2, 3},
	{0, 1, 3, 2}
};

static NSRect ITET_Z_BLOCK_RECTS[2] = {
	{1, 1, 2, 3},
	{0, 2, 3, 2}
};

static NSRect ITET_S_BLOCK_RECTS[2] = {
	{0, 1, 2, 3},
	{0, 2, 3, 2}
};

static NSRect ITET_T_BLOCK_RECTS[4] = {
	{0, 1, 2, 3},
	{0, 2, 3, 2},
	{1, 1, 2, 3},
	{0, 1, 3, 2}
};

- (NSImage*)previewImageWithTheme:(iTetTheme*)theme
{
	// Create an image of the block using a default size
	NSSize cellSize = [theme cellSize];
	NSImage* blockImage = [self imageWithSize:NSMakeSize((cellSize.width * ITET_BLOCK_WIDTH), (cellSize.height * ITET_BLOCK_HEIGHT))
										theme:theme];
	
	// Determine the area of the image to crop
	NSRect blockRect;
	switch (type)
	{
		case I_block:
			blockRect = ITET_I_BLOCK_RECTS[orientation];
			break;
		case O_block:
			blockRect = ITET_O_BLOCK_RECT;
			break;
		case J_block:
			blockRect = ITET_J_BLOCK_RECTS[orientation];
			break;
		case L_block:
			blockRect = ITET_L_BLOCK_RECTS[orientation];
			break;
		case Z_block:
			blockRect = ITET_Z_BLOCK_RECTS[orientation];
			break;
		case S_block:
			blockRect = ITET_S_BLOCK_RECTS[orientation];
			break;
		case T_block:
			blockRect = ITET_T_BLOCK_RECTS[orientation];
			break;
		default:
			NSLog(@"WARNING: iTetBlock previewImageWithTheme called with invalid block type");
			return nil;
	}
	
	// Scale the area to the same proportions as the default image size
	blockRect.origin.x *= cellSize.width;
	blockRect.origin.y *= cellSize.height;
	blockRect.size.width *= cellSize.width;
	blockRect.size.height *= cellSize.height;
	
	// Create a blank image of the final desired size
	NSImage* previewImage = [[[NSImage alloc] initWithSize:blockRect.size] autorelease];
	
	// Prepare for drawing
	[previewImage lockFocus];
	
	// Draw the relevant portion of the default image into the final image
	[blockImage drawInRect:NSMakeRect(0, 0, blockRect.size.width, blockRect.size.height)
				  fromRect:blockRect
				 operation:NSCompositeSourceOver
				  fraction:1.0];
	
	// Finished drawing
	[previewImage unlockFocus];
	
	// Return the image
	return previewImage;
}

@end
