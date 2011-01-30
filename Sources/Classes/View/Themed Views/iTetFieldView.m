//
//  iTetFieldView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
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
	[fieldToViewTransform release];
	[viewToFieldTransform release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing/Geometry

- (BOOL)isOpaque
{
	return NO;
}

- (NSImage*)backgroundImage
{
	return [[self theme] remoteFieldBackground];
}

- (NSImage*)imageForCellType:(uint8_t)cellType
{
	return [[self theme] remoteFieldCellImageForCellType:cellType];
}

- (void)drawRect:(NSRect)dirtyRect
{
	// Clip the dirty rect to the view's field-frame
	NSRect croppedDirtyRect = NSIntersectionRect(dirtyRect, [self fieldFrame]);
	if (NSIsEmptyRect(croppedDirtyRect))
		return;
	
	// Transform the graphics context's coordinate system to match the field
	[[self fieldToViewTransform] concat];
	
	// Convert the dirty rect to the new coordinate system
	NSRect fieldDirtyRect;
	fieldDirtyRect.origin = [[self viewToFieldTransform] transformPoint:croppedDirtyRect.origin];
	fieldDirtyRect.size = [[self viewToFieldTransform] transformSize:croppedDirtyRect.size];
	
	// Scale the dirty rect to the background
	NSSize cellSize = [[self theme] cellSize];
	NSSize backgroundSize = [[self backgroundImage] size];
	CGFloat xScale = (backgroundSize.width / (ITET_FIELD_WIDTH * cellSize.width));
	CGFloat yScale = (backgroundSize.height / (ITET_FIELD_HEIGHT * cellSize.height));
	NSRect backgroundDirtyRect;
	backgroundDirtyRect.origin.x = (fieldDirtyRect.origin.x * xScale);
	backgroundDirtyRect.origin.y = (fieldDirtyRect.origin.y * yScale);
	backgroundDirtyRect.size.width = (fieldDirtyRect.size.width * xScale);
	backgroundDirtyRect.size.height = (fieldDirtyRect.size.height * yScale);
	
	// Repaint the background behind the dirty rect of the field
	[[self backgroundImage] drawInRect:fieldDirtyRect
							  fromRect:backgroundDirtyRect
							 operation:NSCompositeCopy
							  fraction:1.0];
	
	// If we have no field contents to draw, we're done
	if ([self field] == nil)
		goto done;
	
	// Determine the region of the field that needs to be drawn
	IPSRegion dirtyRegion;
	dirtyRegion.origin.col = round(fieldDirtyRect.origin.x / cellSize.width);
	dirtyRegion.origin.row = round(fieldDirtyRect.origin.y / cellSize.height);
	dirtyRegion.area.width = round(fieldDirtyRect.size.width / cellSize.width);
	dirtyRegion.area.height = round(fieldDirtyRect.size.height / cellSize.height);
	
	// Draw the updated region of the field contents
	FIELD* fieldContents = [[self field] contents];
	NSRect cellRect;
	cellRect.size = cellSize;
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
			NSImage* cellImage = [self imageForCellType:cell];
			
			// Calculate the rect in which to draw the cell
			cellRect.origin.x = (col * cellSize.width);
			cellRect.origin.y = (row * cellSize.height);
			
			// Draw the cell
			[cellImage drawInRect:cellRect
						 fromRect:NSZeroRect
						operation:NSCompositeSourceOver
						 fraction:1.0];
		}
	}
	
done:;
	
	// Revert the graphics context's coordinate system
	[[self viewToFieldTransform] concat];
}

- (NSRect)fieldFrameForViewSize:(NSSize)viewSize
{
	// Get the aspect ratio from the field's dimensions
	CGFloat fieldAspect = ((CGFloat)ITET_FIELD_WIDTH / (CGFloat)ITET_FIELD_HEIGHT);
	
	// Calculate the largest possible subrect of the view that maintains the aspect ratio
	NSRect newFieldFrame;
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
	else
	{
		newFieldFrame.size = viewSize;
	}
	
	// Center the field frame in the view
	newFieldFrame.origin.x = ((viewSize.width - newFieldFrame.size.width) / 2);
	newFieldFrame.origin.y = ((viewSize.height - newFieldFrame.size.height) / 2);
	
	return newFieldFrame;
}

- (NSAffineTransform*)viewTransformForCellSize:(NSSize)cellSize
{
	// Create an affine transform
	NSAffineTransform* newTransform = [NSAffineTransform transform];
	
	// Translate from the view's origin to the origin of the field
	[newTransform translateXBy:[self fieldFrame].origin.x
						   yBy:[self fieldFrame].origin.y];
	
	// Scale from the size of the background to the size of the field as drawn in the view
	[newTransform scaleXBy:([self fieldFrame].size.width / (ITET_FIELD_WIDTH * cellSize.width))
					   yBy:([self fieldFrame].size.height / (ITET_FIELD_HEIGHT * cellSize.height))];
	
	return newTransform;
}

- (void)updateViewTransforms
{
	// Calculate the graphics context transform (and its inverse)
	NSAffineTransform* newTransform = [self viewTransformForCellSize:[[self theme] cellSize]];
	[self setFieldToViewTransform:newTransform];
	[newTransform invert];
	[self setViewToFieldTransform:newTransform];
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
	dirtyRect.origin = [[self fieldToViewTransform] transformPoint:dirtyRect.origin];
	dirtyRect.size = [[self fieldToViewTransform] transformSize:dirtyRect.size];
	
	[self setNeedsDisplayInRect:dirtyRect];
}
@synthesize field;

@synthesize fieldFrame;

- (void)setTheme:(iTetTheme*)newTheme
{
	// Update the theme
	[super setTheme:newTheme];
	
	// Recalculate the graphics context transform, based on the theme's cell size
	[self updateViewTransforms];
}

@synthesize fieldToViewTransform;
@synthesize viewToFieldTransform;

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
