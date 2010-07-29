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
	// Calculate the graphics context transform (and its inverse)
	NSAffineTransform* newTransform = [NSAffineTransform transform];
	NSSize viewSize = [self bounds].size;
	NSSize backgroundSize = [[[self theme] background] size];
	[newTransform scaleXBy:(viewSize.width / backgroundSize.width)
					   yBy:(viewSize.height / backgroundSize.height)];
	[self setViewScaleTransform:newTransform];
	[newTransform invert];
	[self setReverseTransform:newTransform];
}

- (void)dealloc
{
	[field release];
	[viewScaleTransform release];
	[reverseTransform release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	NSLog(@"DEBUG: field view drawRect: called with dirtyRect: %@", NSStringFromRect(dirtyRect));
	
	// Push the graphics context onto the stack
	NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
	[graphicsContext saveGraphicsState];
	
	// Apply our scale transform to the graphics context
	[[self viewScaleTransform] concat];
	
	// Get the background image from the theme
	NSImage* background = [[self theme] background];
	
	// If we have no field to draw, simply draw the background
	if ([self field] == nil)
	{
		[background drawAtPoint:NSZeroPoint
					   fromRect:NSZeroRect
					  operation:NSCompositeCopy
					   fraction:1.0];
		goto done;
	}
	
	// Determine the region of the background to be drawn
	NSRect backgroundRect;
	backgroundRect.origin = [[self reverseTransform] transformPoint:dirtyRect.origin];
	backgroundRect.size = [[self reverseTransform] transformSize:dirtyRect.size];
	
	// Draw the background for the dirty section of the view
	[background drawInRect:backgroundRect
				  fromRect:backgroundRect
				 operation:NSCompositeCopy
				  fraction:1.0];
	
	// Determine the region of the field that needs to be drawn
	NSSize cellSize = [[self theme] cellSize];
	IPSRegion dirtyRegion;
	dirtyRegion.origin.col = floor(backgroundRect.origin.x / cellSize.width);
	dirtyRegion.origin.row = floor(backgroundRect.origin.y / cellSize.height);
	dirtyRegion.area.width = ceil(backgroundRect.size.width / cellSize.width);
	dirtyRegion.area.height = ceil(backgroundRect.size.height / cellSize.height);
	
	// Draw the updated region of the field contents
	NSPoint drawPoint;
	for (NSInteger row = IPSMinRow(dirtyRegion); row <= IPSMaxRow(dirtyRegion); row++)
	{
		for (NSInteger col = IPSMinCol(dirtyRegion); col <= IPSMaxCol(dirtyRegion); col++)
		{
			// Get the cell type
			uint8_t cell = [[self field] cellAtRow:row
											column:col];
			
			// If there is nothing to draw, skip to next iteration of the loop
			if (cell == 0)
				continue;
			
			// Get the image for this cell
			NSImage* cellImage = [[self theme] imageForCellType:cell];
			
			// Determine the point at which to draw the cell
			drawPoint.x = col * cellSize.width;
			drawPoint.y = row * cellSize.height;
			
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
	
	// If there's no new field, redraw the empty view
	if (newField == nil)
	{
		[self setNeedsDisplay:YES];
		return;
	}
	
	// Otherwise, determine the portion of the view that needs to be redrawn
	IPSRegion fieldDirtyRegion = [newField updateDirtyRegion];
	
	NSLog(@"DEBUG: -setNeedsDisplay: for region: %@", IPSStringFromRegion(fieldDirtyRegion));
	
	// If the field is unchanged, no redraw is necessary
	if (IPSEqualRegions(fieldDirtyRegion, IPSEmptyRegion))
		return;
	
	// Check if the entire view needs to be redrawn
	if (IPSEqualRegions(fieldDirtyRegion, iTetFullFieldDirtyRegion))
	{
		[self setNeedsDisplay:YES];
		return;
	}
	
	// If the dirty region is only a portion of the field, calculate the corresponding view rect
	NSSize cellSize = [[self theme] cellSize];
	NSRect dirtyRect;
	dirtyRect.origin.x = (fieldDirtyRegion.origin.col * cellSize.width);
	dirtyRect.origin.y = (fieldDirtyRegion.origin.row * cellSize.height);
	dirtyRect.size.width = (fieldDirtyRegion.area.width * cellSize.width);
	dirtyRect.size.height = (fieldDirtyRegion.area.height * cellSize.height);
	
	NSLog(@"         dirtyRect before transform: %@", NSStringFromRect(dirtyRect));
	
	// Convert the rect to the transformed coordinate system
	dirtyRect.origin = [[self viewScaleTransform] transformPoint:dirtyRect.origin];
	dirtyRect.size = [[self viewScaleTransform] transformSize:dirtyRect.size];
	
	NSLog(@"          dirtyRect after transform: %@", NSStringFromRect(dirtyRect));
	
	[self setNeedsDisplayInRect:dirtyRect];
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
	[newTransform invert];
	[self setReverseTransform:newTransform];
	
	// Just to be safe...
	[self setNeedsDisplay:YES];
}

@synthesize viewScaleTransform;
@synthesize reverseTransform;

@end
