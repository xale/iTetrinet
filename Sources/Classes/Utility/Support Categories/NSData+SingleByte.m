//
//  NSData+SingleByte.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/10/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "NSData+SingleByte.h"

@implementation NSData (SingleByte)

+ (id)dataWithByte:(uint8_t)byte
{
	const uint8_t buf[1] = {byte};
	return [self dataWithBytes:buf
						length:1];
}

- (NSData*)dataByAppendingByte:(uint8_t)byte
{
	NSUInteger length = [self length];
	uint8_t buf[(length + 1)];
	memcpy(buf, [self bytes], length);
	buf[length] = byte;
	
	return [NSData dataWithBytes:buf
						  length:(length + 1)];
}

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

@end

@implementation NSMutableData (SingleByte)

- (void)appendByte:(uint8_t)byte
{
	const uint8_t buf[1] = {byte};
	[self appendBytes:buf
			   length:1];
}

- (void)insertByte:(uint8_t)byte
		   atIndex:(NSUInteger)index
{
	const uint8_t buf[1] = {byte};
	[self replaceBytesInRange:NSMakeRange(index, 0)
					withBytes:buf
					   length:1];
}

@end
