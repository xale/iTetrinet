//
//  NSData+Subdata.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "NSData+Subdata.h"

@implementation NSData (Subdata)

#pragma mark -
#pragma mark Subdata by Index

- (NSData*)subdataToIndex:(NSUInteger)index
{
	return [self subdataWithRange:NSMakeRange(0, index)];
}

- (NSData*)subdataFromIndex:(NSUInteger)index
{
	return [self subdataWithRange:NSMakeRange(index, ([self length] - index))];
}

@end
