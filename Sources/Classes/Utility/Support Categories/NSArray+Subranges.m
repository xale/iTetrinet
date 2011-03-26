//
//  NSArray+Subranges.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/10/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "NSArray+Subranges.h"

@implementation NSArray(Subranges)

- (NSArray*)subarrayFromIndex:(NSUInteger)index
{
	return [self subarrayWithRange:NSMakeRange(index, ([self count] - index))];
}

- (NSArray*)subarrayToIndex:(NSUInteger)index
{
	return [self subarrayWithRange:NSMakeRange(0, index)];
}

@end
