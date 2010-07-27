//
//  iTetFieldView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetFieldView.h"
#import "iTetField.h"

@implementation iTetFieldView

+ (void)initialize
{
	[self exposeBinding:@"field"];
}

- (void)awakeFromNib
{
	// Calculate the graphics context transform
	NSAffineTransform* newTransform = [NSAffineTransform transform];
	NSSize viewSize = [self bounds].size;
	NSSize backgroundSize = [[[self theme] background] size];
	[newTransform scaleXBy:(viewSize.width / backgroundSize.width)
					   yBy:(viewSize.height / backgroundSize.height)];
	[self setViewScaleTransform:newTransform];
}

- (void)dealloc
{
	[field release];
	[viewScaleTransform release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	// Get the graphics context we are drawing to
	NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
	
	// Push the existing context onto the context stack
	[graphicsContext saveGraphicsState];
	
	// Get the background image from the theme
	NSImage* background = [[self theme] background];
	
	// Apply our scale transform to the graphics context
	[[self viewScaleTransform] concat];
	
	// Draw the background
	[background drawAtPoint:NSZeroPoint
				   fromRect:NSZeroRect
				  operation:NSCompositeCopy
				   fraction:1.0];
	
	// If we have no field contents to draw, we are finished
	if ([self field] == nil)
		goto done;
	
	// Draw the field contents
	uint8_t cell;
	NSImage* cellImage;
	NSPoint drawPoint = NSZeroPoint;
	for (NSInteger row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (NSInteger col = 0; col < ITET_FIELD_WIDTH; col++)
		{
			// Get the cell type
			cell = [[self field] cellAtRow:row
									column:col];
			
			// If there is nothing to draw, skip to next iteration of loop
			if (cell == 0)
				continue;
			
			// Get the image for this cell
			cellImage = [[self theme] imageForCellType:cell];
			
			// Move the point at which to draw the cell
			drawPoint.x = col * [[self theme] cellSize].height;
			drawPoint.y = row * [[self theme] cellSize].width;
			
			// Draw the cell
			[cellImage drawAtPoint:drawPoint
						  fromRect:NSZeroRect
						 operation:NSCompositeSourceOver
						  fraction:1.0];
		}
	}
	
done:;
	
	// Pop the graphics context
	[graphicsContext restoreGraphicsState];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isOpaque
{
	return YES;
}

- (void)setField:(iTetField*)newField
{
	// Swap in new field
	[newField retain];
	[field release];
	field = newField;
	
	[self setNeedsDisplay:YES];
}
@synthesize field;

- (void)setTheme:(iTetTheme*)newTheme
{
	if ([newTheme isEqual:theme])
		return;
	
	[super setTheme:newTheme];
	
	// Recalculate the graphics context transform, based on the theme's background size
	NSAffineTransform* newTransform = [NSAffineTransform transform];
	NSSize viewSize = [self bounds].size;
	NSSize backgroundSize = [[newTheme background] size];
	[newTransform scaleXBy:(viewSize.width / backgroundSize.width)
					   yBy:(viewSize.height / backgroundSize.height)];
	[self setViewScaleTransform:newTransform];
	
	// Just to be safe...
	[self setNeedsDisplay:YES];
}

@synthesize viewScaleTransform;

@end
