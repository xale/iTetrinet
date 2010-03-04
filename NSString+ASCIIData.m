//
//  NSString+ASCIIData.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "NSString+ASCIIData.h"

@implementation NSString (ASCIIData)

+ (id)stringWithASCIIData:(NSData*)asciiData
{
	return [[[self alloc] initWithData:asciiData
							  encoding:NSASCIIStringEncoding] autorelease];
}

@end
