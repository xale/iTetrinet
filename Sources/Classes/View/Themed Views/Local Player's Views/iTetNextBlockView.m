//
//  iTetNextBlockView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNextBlockView.h"
#import "iTetBlock.h"
#import "iTetBlock+Drawing.h"

@implementation iTetNextBlockView

+ (void)initialize
{
	[self exposeBinding:@"block"];
}

- (void)dealloc
{
	[block release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	// Check that there is a block to draw
	if ([self block] == nil)
		return;
	
	// Calculate a cell size for the block, based on the view's size and the maximum dimensions of a block
	NSSize viewSize = [self bounds].size;
	NSSize cellSize = NSMakeSize((viewSize.width / ITET_BLOCK_WIDTH), (viewSize.height / ITET_BLOCK_HEIGHT));
	
	// Normalize to the smaller dimension, to ensure the cells are square
	if (cellSize.width > cellSize.height)
		cellSize.width = cellSize.height;
	else if (cellSize.height > cellSize.width)
		cellSize.height = cellSize.width;
	
	// Create the preview image for the block
	NSImage* blockPreview = [[self block] previewImageWithCellSize:cellSize
															 theme:[self theme]];
	
	// Center the image in the view
	NSPoint drawPoint = NSMakePoint(((viewSize.width - [blockPreview size].width) / 2), ((viewSize.height - [blockPreview size].height) / 2));
	
	// Draw the image
	[blockPreview drawAtPoint:drawPoint
					 fromRect:NSZeroRect
					operation:NSCompositeSourceOver
					 fraction:1.0];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isOpaque
{
	return NO;
}

- (void)setBlock:(iTetBlock*)newBlock
{
	[block autorelease];
	block = [newBlock copy];
	
	[self setNeedsDisplay:YES];
}
@synthesize block;

@end
