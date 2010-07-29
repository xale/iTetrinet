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

static IPSRegion ITET_I_BLOCK_RECTS[2] = {
	{2, 0, 1, 4},	// Horizontal
	{0, 1, 4, 1}	// Vertical
};

static IPSRegion ITET_O_BLOCK_RECT = {2, 1, 2, 2};

static IPSRegion ITET_J_BLOCK_RECTS[4] = {
	{2, 0, 2, 3},	// Protrusion on top
	{1, 1, 3, 2},	// Right
	{1, 0, 2, 3},	// Bottom
	{1, 0, 3, 2}	// Left
};

static IPSRegion ITET_L_BLOCK_RECTS[4] = {
	{2, 0, 2, 3},	// Protrusion on top
	{1, 1, 3, 2},	// Right
	{1, 0, 2, 3},	// Bottom
	{1, 0, 3, 2}	// Left
};

static IPSRegion ITET_Z_BLOCK_RECTS[2] = {
	{2, 0, 2, 3},	// Horizontal
	{1, 1, 3, 2}	// Vertical
};

static IPSRegion ITET_S_BLOCK_RECTS[2] = {
	{2, 0, 2, 3},	// Horizontal
	{1, 0, 3, 2}	// Vertical
};

static IPSRegion ITET_T_BLOCK_RECTS[4] = {
	{2, 0, 2, 3},	// Protrusion on top
	{1, 1, 3, 2},	// Right
	{1, 0, 2, 3},	// Bottom
	{1, 0, 3, 2}	// Left
};

- (NSImage*)previewImageWithTheme:(iTetTheme*)theme
{
	// Create an image of the block using the default cellSize from the theme
	NSImage* blockImage = [self imageWithTheme:theme];
	
	// Determine the area of the image to crop
	IPSRegion boundingRegion = [self boundingRegion];
	
	// Scale the area to the same proportions as the default image size
	NSRect blockRect;
	blockRect.origin.x = (boundingRegion.origin.col * [theme cellSize].width);
	blockRect.origin.y = (boundingRegion.origin.row * [theme cellSize].height);
	blockRect.size.width = (boundingRegion.area.width * [theme cellSize].width);
	blockRect.size.height = (boundingRegion.area.height * [theme cellSize].height);
	
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

- (IPSRegion)boundingRegion
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
			NSAssert1(NO, @"iTetBlock -boundingRegion called with invalid block type: %d", type);
			break;
	}
	
	return IPSEmptyRegion;
}

@end
