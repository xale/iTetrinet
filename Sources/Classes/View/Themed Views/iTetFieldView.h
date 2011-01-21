//
//  iTetFieldView.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//
// A ThemedView subclass used for drawing a player's field (background + blocks)
//

#import <Cocoa/Cocoa.h>
#import "iTetThemedView.h"

@class iTetField;

@interface iTetFieldView : iTetThemedView
{
	iTetField* field;
	NSRect fieldFrame;
	NSAffineTransform* viewTransform;
	NSAffineTransform* reverseTransform;
}

- (NSImage*)backgroundImage;

@property (readwrite, nonatomic, retain) iTetField* field;
@property (readwrite, assign) NSRect fieldFrame;
@property (readwrite, copy) NSAffineTransform* viewTransform;
@property (readwrite, copy) NSAffineTransform* reverseTransform;

@end
