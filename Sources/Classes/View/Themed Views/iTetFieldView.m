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

@interface iTetFieldView (Private)

- (NSRect)fieldFrameForViewSize:(NSSize)viewSize;
- (NSAffineTransform*)scaleTransformForBackgroundOfSize:(NSSize)backgroundSize;
- (void)updateViewTransforms;

@end

@implementation iTetFieldView

+ (void)initialize
{
	[self exposeBinding:@"field"];
}

- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	// Calculate the largest subrect of the view with an aspect ratio appropriate for the field
	fieldFrame = [self fieldFrameForViewSize:frame.size];
	
	// Calculate the view's graphics transform
	[self updateViewTransforms];
	
	return self;
}

- (void)dealloc
{
	[field release];
	[viewScaleTransform release];
	[reverseTransform release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing/Geometry

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{
	// Clip the dirty rect to the view's field-frame
	NSRect fieldDirtyRect = NSIntersectionRect(dirtyRect, [self fieldFrame]);
	if (NSIsEmptyRect(fieldDirtyRect))
		return;
	
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
	backgroundRect.origin = [[self reverseTransform] transformPoint:fieldDirtyRect.origin];
	backgroundRect.size = [[self reverseTransform] transformSize:fieldDirtyRect.size];
	
	// Draw the background for the dirty section of the view
	[background drawInRect:backgroundRect
				  fromRect:backgroundRect
				 operation:NSCompositeCopy
				  fraction:1.0];
	
	// Determine the region of the field that needs to be drawn
	NSSize cellSize = [[self theme] cellSize];
	IPSRegion dirtyRegion;
	dirtyRegion.origin.col = MAX(floor(backgroundRect.origin.x / cellSize.width), 0);
	dirtyRegion.origin.row = MAX(floor(backgroundRect.origin.y / cellSize.height), 0);
	dirtyRegion.area.width = MIN(ceil(backgroundRect.size.width / cellSize.width), ITET_FIELD_WIDTH);
	dirtyRegion.area.height = MIN(ceil(backgroundRect.size.height / cellSize.height), ITET_FIELD_HEIGHT);
	
	// Draw the updated region of the field contents
	FIELD* fieldContents = [[self field] contents];
	NSPoint drawPoint;
	for (NSInteger row = IPSMinRow(dirtyRegion); row <= IPSMaxRow(dirtyRegion); row++)
	{
		for (NSInteger col = IPSMinCol(dirtyRegion); col <= IPSMaxCol(dirtyRegion); col++)
		{
			// Get the cell type
			uint8_t cell = (*fieldContents)[row][col];
			
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

- (NSRect)fieldFrameForViewSize:(NSSize)viewSize
{
	// Get the aspect ratio from the field's dimensions
	CGFloat fieldAspect = ((CGFloat)ITET_FIELD_WIDTH / (CGFloat)ITET_FIELD_HEIGHT);
	
	// Calculate the largest possible subrect of the view that maintains the aspect ratio
	NSRect newFieldFrame = NSZeroRect;
	if (viewSize.width > (viewSize.height * fieldAspect))
	{
		newFieldFrame.size.width = (viewSize.height * fieldAspect);
		newFieldFrame.size.height = viewSize.height;
	}
	else if (viewSize.height > (viewSize.width / fieldAspect))
	{
		newFieldFrame.size.width = viewSize.width;
		newFieldFrame.size.height = (viewSize.width / fieldAspect);
	}
	
	// FIXME: center field frame in view
	
	return newFieldFrame;
}

- (NSAffineTransform*)scaleTransformForBackgroundOfSize:(NSSize)backgroundSize
{
	// Create an affine transform
	NSAffineTransform* newTransform = [NSAffineTransform transform];
	
	// Scale from the size of the background to the size of the field as drawn in the view
	[newTransform scaleXBy:([self fieldFrame].size.width / backgroundSize.width)
					   yBy:([self fieldFrame].size.height / backgroundSize.height)];
	
	// Translate from the view's origin to the origin of the field
	[newTransform translateXBy:[self fieldFrame].origin.x
						   yBy:[self fieldFrame].origin.y];
	
	return newTransform;
}

- (void)updateViewTransforms
{
	// Calculate the graphics context transform (and its inverse)
	NSAffineTransform* newTransform = [self scaleTransformForBackgroundOfSize:[[[self theme] background] size]];
	[self setViewScaleTransform:newTransform];
	[newTransform invert];
	[self setReverseTransform:newTransform];
}

#pragma mark -
#pragma mark Accessors

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
	
	// Convert the rect to the transformed coordinate system
	dirtyRect.origin = [[self viewScaleTransform] transformPoint:dirtyRect.origin];
	dirtyRect.size = [[self viewScaleTransform] transformSize:dirtyRect.size];
	
	[self setNeedsDisplayInRect:dirtyRect];
}
@synthesize field;

@synthesize fieldFrame;

- (void)setTheme:(iTetTheme*)newTheme
{
	// Update the theme
	[super setTheme:newTheme];
	
	// Recalculate the graphics context transform, based on the theme's background size
	[self updateViewTransforms];
}

@synthesize viewScaleTransform;
@synthesize reverseTransform;

- (void)setFrame:(NSRect)newFrame
{
	// Recalculate the subrect used for the frame of the field
	[self setFieldFrame:[self fieldFrameForViewSize:newFrame.size]];
	
	// Recalculate the graphics context transform, based on the new frame
	[self updateViewTransforms];
	
	// Update the frame
	[super setFrame:newFrame];
}

@end
