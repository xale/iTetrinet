//
//  iTetBlock+Drawing.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetBlock+Drawing.h"
#import "iTetTheme.h"

@implementation iTetBlock (Drawing)

- (NSImage*)imageWithTheme:(iTetTheme*)theme
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
	
	// Return the image
	return image;
}

// FIXME: convert to IPSRegions
static NSRect ITET_I_BLOCK_RECTS[2] = {
	{0, 2, 4, 1},	// Horizontal
	{1, 0, 1, 4}	// Vertical
};

static NSRect ITET_O_BLOCK_RECT = {1, 2, 2, 2};

static NSRect ITET_J_BLOCK_RECTS[4] = {
	{0, 2, 3, 2},	// Protrusion on top
	{1, 1, 2, 3},	// Right
	{0, 1, 3, 2},	// Bottom
	{0, 1, 2, 3}	// Left
};

static NSRect ITET_L_BLOCK_RECTS[4] = {
	{0, 2, 3, 2},	// Protrusion on top
	{1, 1, 2, 3},	// Right
	{0, 1, 3, 2},	// Bottom
	{0, 1, 2, 3}	// Left
};

static NSRect ITET_Z_BLOCK_RECTS[2] = {
	{0, 2, 3, 2},	// Horizontal
	{1, 1, 2, 3}	// Vertical
};

static NSRect ITET_S_BLOCK_RECTS[2] = {
	{0, 2, 3, 2},	// Horizontal
	{0, 1, 2, 3}	// Vertical
};

static NSRect ITET_T_BLOCK_RECTS[4] = {
	{0, 2, 3, 2},	// Protrusion on top
	{1, 1, 2, 3},	// Right
	{0, 1, 3, 2},	// Bottom
	{0, 1, 2, 3}	// Left
};

- (NSImage*)previewImageWithTheme:(iTetTheme*)theme
{
	// Create an image of the block using the default cellSize from the theme
	NSImage* blockImage = [self imageWithTheme:theme];
	
	// Determine the area of the image to crop
	NSRect blockRect = [self boundingRect];
	
	// Scale the area to the same proportions as the default image size
	blockRect.origin.x *= [theme cellSize].width;
	blockRect.origin.y *= [theme cellSize].height;
	blockRect.size.width *= [theme cellSize].width;
	blockRect.size.height *= [theme cellSize].height;
	
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

- (NSRect)boundingRect
{
	switch (type)
	{
		case I_block:
			return ITET_I_BLOCK_RECTS[orientation];
		case O_block:
			return ITET_O_BLOCK_RECT;
		case J_block:
			return ITET_J_BLOCK_RECTS[orientation];
		case L_block:
			return ITET_L_BLOCK_RECTS[orientation];
		case Z_block:
			return ITET_Z_BLOCK_RECTS[orientation];
		case S_block:
			return ITET_S_BLOCK_RECTS[orientation];
		case T_block:
			return ITET_T_BLOCK_RECTS[orientation];
		default:
			NSAssert1(NO, @"iTetBlock -previewImageWithTheme: called with invalid block type: %d", type);
			break;
	}
	
	return NSZeroRect;
}

@end
