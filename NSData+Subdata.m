//
//  NSData+Subdata.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
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
