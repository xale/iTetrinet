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
	
	// Get the block's location
	NSPoint blockLocation = NSMakePoint(([[self block] colPos] * [[self theme] cellSize].width),
										([[self block] rowPos] * [[self theme] cellSize].height));
	
	// Push the graphics context onto the stack
	NSGraphicsContext* context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	
	// Apply our scale transform to the graphics context
	[[self viewScaleTransform] concat];
	
	// Draw the block image to the view
	[blockImage drawAtPoint:blockLocation
				   fromRect:NSZeroRect
				  operation:NSCompositeSourceOver
				   fraction:1.0];
	
	// Pop the graphics context
	[context restoreGraphicsState];
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
	// Check if we have a delegate, and whether or not it is interested
	if ((eventDelegate != nil) && [eventDelegate respondsToSelector:@selector(keyPressed:onLocalFieldView:)])
	{
		// Inform the delegate
		[eventDelegate keyPressed:[iTetKeyNamePair keyNamePairFromKeyEvent:keyEvent]
				 onLocalFieldView:self];
	}
}

#pragma mark -
#pragma mark Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if ([object isKindOfClass:[iTetBlock class]])
	{
		// FIXME: WRITME: calculate dirty rect
		[self setNeedsDisplay:YES];
		return;
	}
	
	[super observeValueForKeyPath:keyPath
						 ofObject:object
						   change:change
						  context:context];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)setBlock:(iTetBlock*)newBlock
{
	// Stop observing the old block
	[block removeObserver:self forKeyPath:@"rowPos"];
	[block removeObserver:self forKeyPath:@"colPos"];
	[block removeObserver:self forKeyPath:@"orientation"];
	
	// Swap the new block for the old
	[newBlock retain];
	[block release];
	block = newBlock;
	
	// Start observing the new block
	[block addObserver:self forKeyPath:@"rowPos" options:0 context:NULL];
	[block addObserver:self forKeyPath:@"colPos" options:0 context:NULL];
	[block addObserver:self forKeyPath:@"orientation" options:0 context:NULL];
	
	// Calculate the rect of the view that needs to be redrawn
	NSRect boundingRect = [newBlock boundingRect];
	NSSize cellSize = [[self theme] cellSize];
	NSRect dirtyRect;
	dirtyRect.origin.x = (([newBlock colPos] + boundingRect.origin.x) * cellSize.width);
	dirtyRect.origin.y = (([newBlock rowPos] + boundingRect.origin.y) * cellSize.height);
	dirtyRect.size.width = (boundingRect.size.width * cellSize.width);
	dirtyRect.size.height = (boundingRect.size.height * cellSize.height);
	
	// Convert to the transformed coordinate system
	dirtyRect.origin = [[self viewScaleTransform] transformPoint:dirtyRect.origin];
	dirtyRect.size = [[self viewScaleTransform] transformSize:dirtyRect.size];
	
	// FIXME: not working
	[self setNeedsDisplayInRect:dirtyRect];
	//[self setNeedsDisplay:YES];
}
@synthesize block;

@end
