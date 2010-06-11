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

- (void)drawRect:(NSRect)rect
{
	// Call the default iTetFieldView drawRect:
	[super drawRect:rect];
	
	// If we have no block to draw, we're done
	if ([self block] == nil)
		return;
	
	// Determine the size at which the block should be drawn
	NSSize cellSize = NSMakeSize(([self bounds].size.width / ITET_FIELD_WIDTH),
								 ([self bounds].size.height / ITET_FIELD_HEIGHT));
	NSSize blockSize = NSMakeSize((4 * cellSize.width), (4 * cellSize.height));
	
	// Draw the block to an image of that size
	NSImage* blockImage = [[self block] imageWithSize:blockSize
												theme:[self theme]];
	
	// Draw the image at the block's position
	NSPoint drawPoint = NSMakePoint(([[self block] colPos] * cellSize.width),
									([[self block] rowPos] * cellSize.height));
	[blockImage drawAtPoint:drawPoint
				   fromRect:NSZeroRect
				  operation:NSCompositeSourceOver
				   fraction:1.0];
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
	
	[self setNeedsDisplay:YES];
}
@synthesize block;

@end
