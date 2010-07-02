//
//  iTetSpecialsView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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

#define ITET_SPECIALS_VIEW_BORDER_LINE_WIDTH		1.0
#define ITET_SPECIALS_VIEW_DIVIDER_LINE_WIDTH		0.5
#define ITET_SPECIALS_VIEW_HIGHLIGHT_COLOR_ALPHA	0.6

- (void)drawRect:(NSRect)rect
{
	// Calculate the size of the background
	CGFloat borderWidth = ITET_SPECIALS_VIEW_BORDER_LINE_WIDTH;
	NSRect backgroundRect = NSInsetRect([self bounds], borderWidth, borderWidth);
	
	// If a specials capacity has been set, resize the background to indicate it
	if ([self capacity] > 0)
	{
		// Calculate the width of the resized background (integer multiple of the rect's height)
		CGFloat adjustedWidth = (backgroundRect.size.height * [self capacity]);
		
		// Check that the resized background is not too large to draw
		if (adjustedWidth < backgroundRect.size.width)
			backgroundRect.size.width = adjustedWidth;
	}
	
	// Fill the background with white
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect:backgroundRect];
	
	// Add lines to deliniate spots for specials
	[[NSColor lightGrayColor] setStroke];
	CGFloat x = backgroundRect.origin.x + backgroundRect.size.height;
	for (; x < NSMaxX(backgroundRect); x += backgroundRect.size.height)
	{
		[NSBezierPath strokeLineFromPoint:NSMakePoint(x, NSMinY(backgroundRect))
								  toPoint:NSMakePoint(x, NSMaxX(backgroundRect))];
	}
	
	// Draw a border around the background
	[[NSColor lightGrayColor] setStroke];
	NSRect borderRect = NSInsetRect(backgroundRect, -(borderWidth / 2), -(borderWidth / 2));
	[NSBezierPath strokeRect:borderRect];
	
	// Darken the top edge of the border, to give a "shadowed" effect
	[[NSColor grayColor] setStroke];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(borderRect), NSMaxY(borderRect))
							  toPoint:NSMakePoint(NSMaxX(borderRect), NSMaxY(borderRect))];
	
	// If we have specials to draw, scale the graphics context and draw them
	if ((specials != nil) && ([specials count] > 0))
	{
		// Get the graphics context, and push a copy onto the stack
		NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
		[graphicsContext saveGraphicsState];
		
		// Create a scale transform from the cell height to the height of the view
		NSAffineTransform* scaleTransform = [NSAffineTransform transform];
		[scaleTransform scaleBy:(backgroundRect.size.height / [[self theme] cellSize].height)];
		
		// Apply the transform to the graphics context
		[scaleTransform concat];
		
		// Calculate the new background rect
		backgroundRect.origin = [scaleTransform transformPoint:backgroundRect.origin];
		backgroundRect.size = [scaleTransform transformSize:backgroundRect.size];
		
		// Get the image for the first special in the queue
		NSImage* specialImage;
		NSPoint drawPoint = NSMakePoint(NSMinX(backgroundRect), NSMinY(backgroundRect));
		
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
			if (drawPoint.x > NSMaxX(backgroundRect))
				break;
		}
		
		// Highlight the active special
		NSRect selectionRect = backgroundRect;
		selectionRect.size.width = selectionRect.size.height;
		NSColor* highlightColor = [[NSColor selectedControlColor] colorWithAlphaComponent:ITET_SPECIALS_VIEW_HIGHLIGHT_COLOR_ALPHA];
		[highlightColor setFill];
		[NSBezierPath fillRect:selectionRect];
		
		// Pop the graphics context
		[graphicsContext restoreGraphicsState];
	}
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isOpaque
{
	return NO;
}

- (void)setSpecials:(NSArray*)newSpecials
{
	NSArray* temp = [newSpecials copy];
	[specials release];
	specials = temp;
	
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
