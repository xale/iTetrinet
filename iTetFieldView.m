//
//  iTetFieldView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetFieldView.h"
#import "iTetField.h"

@implementation iTetFieldView

+ (void)initialize
{
	[self exposeBinding:@"field"];
}

- (void)dealloc
{
	[field release];
	
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
	NSSize bgSize = [background size];
	
	NSSize viewSize = [self bounds].size;
	
	// Create an affine transform from the background's size to the view's size
	NSAffineTransform* scaleTransform = [NSAffineTransform transform];
	[scaleTransform scaleXBy:(viewSize.width / bgSize.width)
				   yBy:(viewSize.height / bgSize.height)];
	
	// Concatenate the transform to the graphics context
	[scaleTransform concat];
	
	// Draw the background
	[background drawAtPoint:NSZeroPoint
			   fromRect:NSZeroRect
			  operation:NSCompositeCopy
			   fraction:1.0];
	
	// If we have no field contents to draw, we are finished
	if ([self field] == nil)
	{
		// Pop graphics context before returning
		[graphicsContext restoreGraphicsState];
		return;
	}
	
	// Draw the field contents
	char cell;
	NSImage* cellImage;
	NSPoint drawPoint = NSZeroPoint;
	for (int row = 0; row < ITET_FIELD_HEIGHT; row++)
	{
		for (int col = 0; col < ITET_FIELD_WIDTH; col++)
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
	
	// Pop the graphics context
	[graphicsContext restoreGraphicsState];
}

#pragma mark -
#pragma mark Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
			    ofObject:(id)object
				change:(NSDictionary *)change
			     context:(void *)context
{
	if ([object isKindOfClass:[iTetField class]])
	{
		[self setNeedsDisplay:YES];
		return;
	}
	
	[super observeValueForKeyPath:keyPath
				   ofObject:object
				     change:change
				    context:context];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isOpaque
{
	return YES;
}

- (void)setField:(iTetField*)newField
{
	[self willChangeValueForKey:@"field"];
	
	// Stop observing the old field
	[field removeObserver:self forKeyPath:@"contents"];
	
	// Swap in new field
	[newField retain];
	[field release];
	field = newField;
	
	// Start observing the new field
	[field addObserver:self forKeyPath:@"contents" options:0 context:NULL];
	
	[self didChangeValueForKey:@"field"];
	
	[self setNeedsDisplay:YES];
}
@synthesize field;

@end
