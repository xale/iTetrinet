//
//  NSMutableData+SingleByte.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/10/09.
//

#import "NSMutableData+SingleByte.h"

@implementation NSMutableData (SingleByte)

- (void)appendByte:(uint8_t)byte
{
	uint8_t buf[1] = {byte};
	[self appendBytes:buf
			   length:1];
}

- (void)insertByte:(uint8_t)byte
		   atIndex:(NSUInteger)index
{
	uint8_t buf[1] = {byte};
	[self replaceBytesInRange:NSMakeRange(index, 0)
					withBytes:buf
					   length:1];
}

@end
