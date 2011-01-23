//
//  iTetSpecialsView.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//
// A ThemedView subclass that draws the local player's list of specials.

#import <Cocoa/Cocoa.h>
#import "iTetThemedView.h"

@interface iTetSpecialsView : iTetThemedView
{
	NSArray* specials;
	NSInteger capacity;
	NSAffineTransform* viewScaleTransform;
}

@property (readwrite, nonatomic, copy) NSArray* specials;
@property (readwrite, nonatomic, assign) NSInteger capacity;
@property (readwrite, retain) NSAffineTransform* viewScaleTransform;

@end
