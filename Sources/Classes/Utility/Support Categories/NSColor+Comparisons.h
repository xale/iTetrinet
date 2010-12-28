//
//  NSColor+Comparisons.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Comparisons)

- (BOOL)hasSameRGBValuesAsColor:(NSColor*)color;

@end
