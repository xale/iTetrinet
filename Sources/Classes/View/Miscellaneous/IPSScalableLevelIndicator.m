//
//  IPSScalableLevelIndicator.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/28/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "IPSScalableLevelIndicator.h"

#define DEFAULT_NSLEVELINDICATOR_HEIGHT	(18.0)

@implementation IPSScalableLevelIndicator

- (void)drawRect:(NSRect)dirtyRect
{
	// Get the graphics context we are drawing to
	NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
	
	// Push the existing context onto the context stack
	[graphicsContext saveGraphicsState];
	
	// Create an affine transform from the default NSLevelIndicator height to this view's height
	CGFloat viewHeight = [self frame].size.height;
	NSAffineTransform* scaleTransform = [NSAffineTransform transform];
	[scaleTransform scaleXBy:1.0
						 yBy:(viewHeight / DEFAULT_NSLEVELINDICATOR_HEIGHT)];
	
	// Concatenate the transform to the graphics context
	[scaleTransform concat];
	
	// Call the NSLevelIndicator -drawRect: with the transformed graphics context
	[super drawRect:dirtyRect];
	
	// Pop the graphics context
	[graphicsContext restoreGraphicsState];
}

@end
