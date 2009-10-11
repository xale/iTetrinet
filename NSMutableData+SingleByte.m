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

@end
