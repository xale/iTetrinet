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
	return [[[self alloc] initWithASCIIData:asciiData] autorelease];
}

- (id)initWithASCIIData:(NSData*)asciiData
{
	return [self initWithData:asciiData
					 encoding:NSASCIIStringEncoding];
}

@end
