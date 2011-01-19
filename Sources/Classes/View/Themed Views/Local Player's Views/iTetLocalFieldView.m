//
//  iTetLocalFieldView.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/28/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetLocalFieldView.h"
#import "iTetBlock+Drawing.h"
#import "iTetKeyNamePair.h"

@interface iTetLocalFieldView(Private)

- (NSRect)viewRectOccupiedByBlock:(iTetBlock*)drawBlock;

@end

@implementation iTetLocalFieldView

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

- (void)drawRect:(NSRect)dirtyRect
{
	// Call the default iTetFieldView drawRect:
	[super drawRect:dirtyRect];
	
	// If we have no block to draw, we're done
	if ([self block] == nil)
		return;
	
	// Draw the block to an image
	NSImage* blockImage = [[self block] imageWithTheme:[self theme]];
	
	// Determine the location to draw the block
	IPSCoord blockPosition = [[self block] position];
	NSSize cellSize = [[self theme] cellSize];
	NSPoint blockDrawLocation = NSMakePoint((blockPosition.col * cellSize.width), (blockPosition.row * cellSize.height));
	
	// Apply our scale transform to the graphics context
	[[self viewTransform] concat];
	
	// Draw the block image to the view
	[blockImage drawAtPoint:blockDrawLocation
				   fromRect:NSZeroRect
				  operation:NSCompositeSourceOver
				   fraction:1.0];
	
	// Revert the graphics context
	[[self reverseTransform] concat];
}

#pragma mark -
#pragma mark Event Handling

- (void)keyDown:(NSEvent*)event
{
	[self keyEvent:event];
}

- (void)flagsChanged:(NSEvent*)event
{
	[self keyEvent:event];
}

- (void)keyEvent:(NSEvent*)keyEvent
{
	// Check that the event is a valid key
	iTetKeyNamePair* key = [iTetKeyNamePair keyNamePairFromKeyEvent:keyEvent];
	if (key == nil)
		return;
	
	// Check if we have a delegate, and whether or not it is interested
	if ((eventDelegate != nil) && [eventDelegate respondsToSelector:@selector(keyPressed:onLocalFieldView:)])
	{
		// Inform the delegate
		[eventDelegate keyPressed:key
				 onLocalFieldView:self];
	}
}

#pragma mark -
#pragma mark Accessors

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)setBlock:(iTetBlock*)newBlock
{
	// Swap the new block for the old
	iTetBlock* oldBlock = block;
	[newBlock retain];
	[block release];
	block = newBlock;
	
	// Redraw the rect of the field occupied by the old block
	[self setNeedsDisplayInRect:[self viewRectOccupiedByBlock:oldBlock]];
	
	// Redraw the rect of the view occupied by the new block
	[self setNeedsDisplayInRect:[self viewRectOccupiedByBlock:newBlock]];
}
@synthesize block;

- (NSRect)viewRectOccupiedByBlock:(iTetBlock*)drawBlock
{
	// Retrieve the size of a cell on the background and the dimensions of the block
	NSSize cellSize = [[self theme] cellSize];
	IPSCoord pos = [drawBlock position];
	IPSRegion bounds = [drawBlock boundingRegion];
	
	// Calculate the occupied rect in the background's coordinate system
	NSRect rect;
	rect.origin.x = ((pos.col + bounds.origin.col) * cellSize.width);
	rect.origin.y = ((pos.row + bounds.origin.row) * cellSize.height);
	rect.size.width = (bounds.area.width * cellSize.width);
	rect.size.height = (bounds.area.height * cellSize.height);
	
	// Convert to the view's coordinate system
	rect.origin = [[self viewTransform] transformPoint:rect.origin];
	rect.size = [[self viewTransform] transformSize:rect.size];
	return rect;
}

@end
