//
//  NSData+Searching.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "NSData+Searching.h"

@implementation NSData (Searching)

#pragma mark -
#pragma mark Byte Searching

- (NSUInteger)indexOfByte:(uint8_t)byte
{
	const uint8_t* rawData = [self bytes];
	
	for (NSUInteger index = 0; index < [self length]; index++)
	{
		if (rawData[index] == byte)
			return index;
	}
	
	return NSNotFound;
}

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
