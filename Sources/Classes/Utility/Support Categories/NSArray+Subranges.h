//
//  NSArray+Subranges.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/10/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

/*!
 @category NSArray(Subranges)
 A category on NSArray that adds a pair of methods useful for defining subranges of the array.
 */
@interface NSArray(Subranges)

//! Returns an array containing all elements of the receiver including and after the specified index.
- (NSArray*)subarrayFromIndex:(NSUInteger)index;

//! Returns an array containing all elements of the receiver up to and excluding the specified index.
- (NSArray*)subarrayToIndex:(NSUInteger)index;

@end
