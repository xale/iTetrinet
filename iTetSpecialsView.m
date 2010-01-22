//
//  iTetSpecialsView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetSpecialsView.h"
#import "iTetSpecials.h"

@implementation iTetSpecialsView

+ (void)initialize
{
	[self exposeBinding:@"specials"];
}

- (void)dealloc
{
	[specials release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

#define LINE_WIDTH	2

- (void)drawRect:(NSRect)rect
{
	// Fill the background
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect:[self bounds]];
	
	// If we have specials to draw, scale the graphics context and draw them
	if ((specials != nil) && ([specials count] > 0))
	{
		// Get the graphics context, and push a copy onto the stack
		NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
		[graphicsContext saveGraphicsState];
		
		// Create a scale transform from the cell height to the height of the view
		NSAffineTransform* scaleTransform = [NSAffineTransform transform];
		[scaleTransform scaleBy:([[self theme] cellSize].height / [self bounds].size.height)];
		
		// Apply the transform to the graphics context
		[scaleTransform concat];
		
		// Get the image for the first special in the queue
		NSUInteger index;
		iTetSpecialType special;
		NSImage* specialImage;
		NSPoint drawPoint = NSZeroPoint;
		
		// Draw the specials
		for (index = 0; index < [specials count]; index++)
		{
			// Get the special and it's image
			special = (iTetSpecialType)[[specials objectAtIndex:index] intValue];
			specialImage = [[self theme] imageForCellType:(char)special];
			
			// Draw the special
			[specialImage drawAtPoint:drawPoint
					     fromRect:NSZeroRect
					    operation:NSCompositeCopy
					     fraction:1.0];
			
			// Move the drawing point to the next position
			drawPoint.x += [[self theme] cellSize].width;
			
			// Check that we are still on the view
			if (drawPoint.x > [self bounds].size.width)
				break;
		}
		
		// Pop the graphics context
		[graphicsContext restoreGraphicsState];
	}
	
	// Draw a red box around the first (active) special
	CGFloat boxEdgeLength = [self bounds].size.height - (LINE_WIDTH / 2) - 1;
	NSRect boxRect = NSMakeRect((LINE_WIDTH / 2), (LINE_WIDTH / 2),
					    boxEdgeLength, boxEdgeLength);
	[[NSColor redColor] setStroke];
	[NSBezierPath setDefaultLineWidth:LINE_WIDTH];
	[NSBezierPath strokeRect:boxRect];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isOpaque
{
	return YES;
}

- (void)setSpecials:(NSArray*)newSpecials
{
	[self willChangeValueForKey:@"specials"];
	[newSpecials retain];
	[specials release];
	specials = newSpecials;
	[self didChangeValueForKey:@"specials"];
	
	[self setNeedsDisplay:YES];
}
@synthesize specials;

@end
