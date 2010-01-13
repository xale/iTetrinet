//
//  iTetLocalFieldView.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/28/09.
//

#import "iTetLocalFieldView.h"
#import "iTetBlock+Drawing.h"
#import "iTetLocalPlayer.h"
#import "iTetKeyNamePair.h"
#import "iTetGameViewController.h" // Quiets warnings on calls to delegate

@implementation iTetLocalFieldView

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	// Call the default iTetFieldView drawRect:
	[super drawRect:rect];
	
	/* FIXME: needs rewrite
	// Get the view's owner as a local player
	iTetLocalPlayer* player = [self ownerAsLocalPlayer];
	
	// If we have no owner, we have nothing else to draw
	if (player == nil)
		return;
	
	// Get the player's active (falling) block
	iTetBlock* currentBlock = [player currentBlock];
	
	// If we have no block to draw, we're done
	if (currentBlock == nil)
		return;
	
	// Determine the size at which the block should be drawn
	NSSize cellSize = NSMakeSize(([self bounds].size.width / ITET_FIELD_WIDTH),
					     ([self bounds].size.height / ITET_FIELD_HEIGHT));
	NSSize blockSize = NSMakeSize((4 * cellSize.width), (4 * cellSize.height));
	
	// Draw the block to an image of that size
	NSImage* blockImage = [currentBlock imageWithSize:blockSize
								  theme:[self theme]];
	
	// Draw the image at the block's position
	NSPoint drawPoint = NSMakePoint(([currentBlock colPos] * cellSize.width),
						  ([currentBlock rowPos] * cellSize.height));
	[blockImage drawAtPoint:drawPoint
			   fromRect:NSZeroRect
			  operation:NSCompositeSourceOver
			   fraction:1.0];
	 */
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

@end
