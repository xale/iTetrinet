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
#import "iTetSpecial.h"

#define ITET_SPECIALS_VIEW_BORDER_LINE_WIDTH		1.0
#define ITET_SPECIALS_VIEW_DIVIDER_LINE_WIDTH		0.5
#define ITET_SPECIALS_VIEW_HIGHLIGHT_COLOR_ALPHA	0.6

@implementation iTetSpecialsView

+ (void)initialize
{
	[self exposeBinding:@"specials"];
	[self exposeBinding:@"capacity"];
}

- (void)awakeFromNib
{
	// Calculate the graphics context transform
	NSRect backgroundRect = NSInsetRect([self bounds], ITET_SPECIALS_VIEW_BORDER_LINE_WIDTH, ITET_SPECIALS_VIEW_BORDER_LINE_WIDTH);
	NSAffineTransform* newTransform = [NSAffineTransform transform];
	[newTransform translateXBy:backgroundRect.origin.x
						   yBy:backgroundRect.origin.y];
	[newTransform scaleBy:(backgroundRect.size.height / [[self theme] cellSize].height)];
	[self setViewScaleTransform:newTransform];
}

- (void)dealloc
{
	[specials release];
	[viewScaleTransform release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	// Calculate the size of the background
	CGFloat borderWidth = ITET_SPECIALS_VIEW_BORDER_LINE_WIDTH;
	NSRect backgroundRect = NSInsetRect([self bounds], borderWidth, borderWidth);
	
	// Determine the maximum (integer) number of specials we can draw in the background bounds
	NSInteger maxSpecials = (backgroundRect.size.width / backgroundRect.size.height);
	
	// If a specials capacity has been set, ensure that the maximum number of specials is equal or less
	if ([self capacity] > 0)
	{
		maxSpecials = MIN([self capacity], maxSpecials);
	}
	
	// Resize the background to exactly fit the maximum number of specials
	backgroundRect.size.width = (backgroundRect.size.height * maxSpecials);
	
	// Fill the background with white
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect:backgroundRect];
	
	// Add lines to deliniate spots for specials
	[[NSColor lightGrayColor] setStroke];
	[NSBezierPath setDefaultLineWidth:borderWidth];
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
		
		// Apply the transform to the graphics context
		[[self viewScaleTransform] concat];
		
		// Draw the specials (in reverse order)
		NSInteger specialNum = 0;
		for (iTetSpecial* special in [specials reverseObjectEnumerator])
		{
			// Get the next special's image
			NSImage* specialImage = [[self theme] imageForCellType:[special cellValue]];
			
			// Draw the special
			[specialImage drawAtPoint:NSMakePoint((specialNum * [[self theme] cellSize].width), 0)
							 fromRect:NSZeroRect
							operation:NSCompositeSourceOver
							 fraction:1.0];
			
			// Keep track of the number of specials drawn
			if (specialNum < (maxSpecials - 1))
				specialNum++;
			else
				break;
		}
		
		// Pop the graphics context
		[graphicsContext restoreGraphicsState];
		
		// Highlight the active special
		NSRect selectionRect = backgroundRect;
		selectionRect.size.width = selectionRect.size.height;
		NSColor* highlightColor = [[NSColor selectedControlColor] colorWithAlphaComponent:ITET_SPECIALS_VIEW_HIGHLIGHT_COLOR_ALPHA];
		[highlightColor setFill];
		[NSBezierPath fillRect:selectionRect];
	}
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isOpaque
{
	return NO;
}

- (void)setTheme:(iTetTheme*)newTheme
{
	if ([newTheme isEqual:theme])
		return;
	
	[super setTheme:newTheme];
	
	// Recalculate the graphics context transform, based on the theme's cellSize
	NSRect backgroundRect = NSInsetRect([self bounds], ITET_SPECIALS_VIEW_BORDER_LINE_WIDTH, ITET_SPECIALS_VIEW_BORDER_LINE_WIDTH);
	NSAffineTransform* newTransform = [NSAffineTransform transform];
	[newTransform translateXBy:backgroundRect.origin.x
						   yBy:backgroundRect.origin.y];
	[newTransform scaleBy:(backgroundRect.size.height / [[self theme] cellSize].height)];
	[self setViewScaleTransform:newTransform];
	
	// Just to be safe...
	[self setNeedsDisplay:YES];
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

@synthesize viewScaleTransform;

@end
