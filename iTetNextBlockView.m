//
//  iTetNextBlockView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetNextBlockView.h"
#import "iTetBlock.h"
#import "iTetBlock+Drawing.h"

@implementation iTetNextBlockView

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
	
	// Ask the block to draw itself to an NSImage of this view's size
	NSImage* blockImage = [[self block] imageWithSize:[self bounds].size
								  theme:[self theme]];
	
	// Draw the image
	[blockImage drawAtPoint:rect.origin
			   fromRect:rect
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
	[block release];
	block = [newBlock retain];
	[self setNeedsDisplay:YES];
}
@synthesize block;

@end
