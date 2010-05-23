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
	[self exposeBinding:@"capacity"];
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
	// Fill the background with white
	[[NSColor whiteColor] setFill];
	
	// Start with the full size of the view
	NSRect boundsRect = [self bounds];
	CGFloat width;
	
	// If a specials capacity has been set, resize the background to indicate it
	if ([self capacity] > 0)
	{
		// Calculate the width of the resized background
		width = (boundsRect.size.height * [self capacity]);
		
		// Check that the resized background fits on the view
		if (width < [self bounds].size.width)
			boundsRect.size.width = width;
	}
	
	// Fill the background
	[NSBezierPath fillRect:boundsRect];
	
	// If we have specials to draw, scale the graphics context and draw them
	if ((specials != nil) && ([specials count] > 0))
	{
		// Get the graphics context, and push a copy onto the stack
		NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
		[graphicsContext saveGraphicsState];
		
		// Create a scale transform from the cell height to the height of the view
		NSAffineTransform* scaleTransform = [NSAffineTransform transform];
		[scaleTransform scaleBy:([self bounds].size.height / [[self theme] cellSize].height)];
		
		// Apply the transform to the graphics context
		[scaleTransform concat];
		
		// Get the image for the first special in the queue
		NSImage* specialImage;
		NSPoint drawPoint = NSZeroPoint;
		
		// Draw the specials (in reverse order)
		for (NSNumber* special in [specials reverseObjectEnumerator])
		{
			// Get the special's image
			specialImage = [[self theme] imageForCellType:[special unsignedCharValue]];
			
			// Draw the special
			[specialImage drawAtPoint:drawPoint
							 fromRect:NSZeroRect
							operation:NSCompositeSourceOver
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
	return NO;
}

- (void)setSpecials:(NSArray*)newSpecials
{
	[specials autorelease];
	specials = [newSpecials copy];
	
	[self setNeedsDisplay:YES];
}
@synthesize specials;

- (void)setCapacity:(NSInteger)newCapacity
{
	capacity = newCapacity;
	
	[self setNeedsDisplay:YES];
}
@synthesize capacity;

@end
