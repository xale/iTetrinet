//
//  iTetSpecialsView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetSpecialsView.h"
#import "iTetLocalPlayer.h"
#import "iTetSpecials.h"
#import "Queue.h"

@implementation iTetSpecialsView

- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	return self;
}

#pragma mark -
#pragma mark Drawing

#define LINE_WIDTH	2

- (void)drawRect:(NSRect)rect
{
	// Fill the background
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect:rect];
	
	/*
	// Draw the red line after the first special
	[[NSColor redColor] setStroke];
	NSPoint top = NSMakePoint(([theme cellSize].width + (LINE_WIDTH / 2)),
					  [self bounds].size.height);
	NSPoint bottom = NSMakePoint(top.x, 0);
	[NSBezierPath setDefaultLineWidth:LINE_WIDTH];
	[NSBezierPath strokeLineFromPoint:top
					  toPoint:bottom];
	 */
	
	/* FIXME: TESTING
	// Get the view's owner as a local player
	iTetLocalPlayer* player = [self ownerAsLocalPlayer];
	
	// If we have no owner, we have nothing else to draw
	if (player == nil)
		return;
	
	// Get the player's queue of specials
	NSArray* specials = [[player specialsQueue] allObjects];
	 */
	
	NSMutableArray* specials = [NSMutableArray array];
	
	for (int i = 0; i < 20; i++)
	{
		[specials addObject:[NSNumber numberWithInt:iTetSpecialTypeFromNumber((random() % ITET_NUM_SPECIAL_TYPES) + 1)]];
	}
	
	NSLog(@"DEBUG: specials: %@", specials);
	
	// If the player has no specials, we're done
	if ([specials count] == 0)
		return;
	
	// Get the graphics context, and push a copy onto the stack
	NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
	[graphicsContext saveGraphicsState];
	
	// Create a scale transform from the cell height to the height of the view
	NSAffineTransform* scaleTransform = [NSAffineTransform transform];
	[scaleTransform scaleBy:([theme cellSize].height / [self bounds].size.height)];
	
	// Apply the transform to the graphics context
	[scaleTransform concat];
	
	// Get the image for the first special in the queue
	NSUInteger index = 0;
	iTetSpecialType special = (iTetSpecialType)[[specials objectAtIndex:index] intValue];
	NSImage* specialImage = [theme imageForCellType:(char)special];
	NSPoint drawPoint = NSZeroPoint;
	
	// Draw the first special
	[specialImage drawAtPoint:drawPoint
			     fromRect:NSZeroRect
			    operation:NSCompositeCopy
			     fraction:1.0];
	
	// Shift the drawing point over (accounting for the red line)
	drawPoint.x += [theme cellSize].width;
	//drawPoint.x += LINE_WIDTH;
	
	// Draw the remaining specials in the queue
	for (index = 1; (index < [specials count]); index++)
	{
		// Get the special and it's image
		special = (iTetSpecialType)[[specials objectAtIndex:index] intValue];
		specialImage = [theme imageForCellType:(char)special];
		
		// Draw the special
		[specialImage drawAtPoint:drawPoint
				     fromRect:NSZeroRect
				    operation:NSCompositeCopy
				     fraction:1.0];
		
		// Move the drawing point to the next position
		drawPoint.x += [theme cellSize].width;
		
		// Check that we are still on the view
		if (drawPoint.x > [self bounds].size.width)
			break;
	}
	
	// Pop the graphics context
	[graphicsContext restoreGraphicsState];
	
	// Draw a red box around the first (active) special
	NSRect boxRect = NSMakeRect((LINE_WIDTH / 2), (LINE_WIDTH / 2),
					    [theme cellSize].width - (LINE_WIDTH / 2),
					    [theme cellSize].height - (LINE_WIDTH / 2));
	
	[[NSColor redColor] setStroke];
	[NSBezierPath setDefaultLineWidth:LINE_WIDTH];
	[NSBezierPath strokeRect:boxRect];
}

#pragma mark -
#pragma mark Accessors

- (iTetLocalPlayer*)ownerAsLocalPlayer
{
	if (owner == nil)
		return nil;
	
	if ([owner isKindOfClass:[iTetLocalPlayer class]])
		return (iTetLocalPlayer*)owner;
	
	NSLog(@"Warning: SpecialsView owned by non-local player");
	return nil;
}

- (BOOL)isOpaque
{
	return YES;
}

@end
