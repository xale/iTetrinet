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

- (void)drawRect:(NSRect)dirtyRect
{
	// Clip the dirty rect to the view's field-frame
	NSRect frameDirtyRect = NSIntersectionRect(dirtyRect, [self fieldFrame]);
	if (NSIsEmptyRect(frameDirtyRect))
		return;
	
	// Apply our scale transform to the graphics context
	[[self fieldToViewTransform] concat];
	
	// Determine the region of the background to be drawn
	NSRect backgroundDirtyRect;
	backgroundDirtyRect.origin = [[self viewToFieldTransform] transformPoint:frameDirtyRect.origin];
	backgroundDirtyRect.size = [[self viewToFieldTransform] transformSize:frameDirtyRect.size];
	
	// Draw the background for the dirty section of the view
	[[self backgroundImage] drawInRect:backgroundDirtyRect
							  fromRect:backgroundDirtyRect
							 operation:NSCompositeCopy
							  fraction:1.0];
	
	// If we have no field to draw, we're done
	if ([self field] == nil)
		goto done;
	
	// Determine the region of the field that needs to be drawn
	NSSize cellSize = [[self theme] cellSize];
	IPSRegion dirtyRegion;
	dirtyRegion.origin.col = MAX(floor(backgroundDirtyRect.origin.x / cellSize.width), 0);
	dirtyRegion.origin.row = MAX(floor(backgroundDirtyRect.origin.y / cellSize.height), 0);
	dirtyRegion.area.width = MIN(ceil(backgroundDirtyRect.size.width / cellSize.width), (ITET_FIELD_WIDTH - dirtyRegion.origin.col));
	dirtyRegion.area.height = MIN(ceil(backgroundDirtyRect.size.height / cellSize.height), (ITET_FIELD_HEIGHT - dirtyRegion.origin.row));
	
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
	
	// Revert the graphics context
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
