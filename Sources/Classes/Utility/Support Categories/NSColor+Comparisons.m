//
//  NSColor+Comparisons.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "NSColor+Comparisons.h"

@implementation NSColor (Comparisons)

- (BOOL)hasSameRGBValuesAsColor:(NSColor*)otherColor
{
	// Convert to a calibrated color space (i.e., one with r, g, and b components)
	NSColor* converted = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	NSColor* convertedOther = [otherColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	// Get the components of the colors
	CGFloat red = [converted redComponent];
	CGFloat green = [converted greenComponent];
	CGFloat blue = [converted blueComponent];
	CGFloat otherRed = [convertedOther redComponent];
	CGFloat otherGreen = [convertedOther greenComponent];
	CGFloat otherBlue = [convertedOther blueComponent];
	
	CGFloat epsilon = (CGFLOAT_IS_DOUBLE)?(DBL_EPSILON):(FLT_EPSILON);
	return ((fabs(red - otherRed) < epsilon) && (fabs(green - otherGreen) < epsilon) && (fabs(blue - otherBlue) < epsilon));
}

@end
