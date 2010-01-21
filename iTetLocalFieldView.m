//
//  iTetLocalFieldView.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/28/09.
//

#import "iTetLocalFieldView.h"
#import "iTetBlock+Drawing.h"
#import "iTetKeyNamePair.h"
#import "iTetGameViewController.h" // Quiets warnings on calls to delegate

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
	[self keyPressed:[iTetKeyNamePair keyNamePairFromKeyEvent:event]];
}

- (void)flagsChanged:(NSEvent*)event
{
	[self keyPressed:[iTetKeyNamePair keyNamePairFromKeyEvent:event]];
}

- (void)keyPressed:(iTetKeyNamePair*)key
{
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
	[self willChangeValueForKey:@"block"];
	[block release];
	block = [newBlock retain];
	[self didChangeValueForKey:@"block"];
	
	[self setNeedsDisplay:YES];
}
@synthesize block;

@end
