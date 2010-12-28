//
//  NSString+MessageData.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "NSString+MessageData.h"

@implementation NSString (MessageData)

+ (id)stringWithMessageData:(NSData*)messageData
{
	// First, attempt to interpret the string as UTF-8
	NSString* decodedString = [self stringWithData:messageData
										  encoding:iTetDefaultStringEncoding];
	if (decodedString != nil)
		return decodedString;
	
	// If that fails, attempt to decode the string as Windows-1252
	decodedString = [self stringWithData:messageData
								encoding:iTetStandardTetrinetStringEncoding];
	if (decodedString != nil)
		return decodedString;
	
	// If even _that_ fails, fall back to ISO Latin 1 (8859-1)
	return [self stringWithData:messageData
					   encoding:iTetFallbackISOStringEncoding];
}

+ (id)stringWithData:(NSData*)data
			encoding:(NSStringEncoding)encoding
{
	return [[[self alloc] initWithBytes:[data bytes]
								 length:[data length]
							   encoding:encoding] autorelease];
}

- (NSData*)messageData
{
	return [self dataUsingEncoding:iTetDefaultStringEncoding];
}

- (NSString*)messageDesignation
{
	return [[self componentsSeparatedByString:@" "] objectAtIndex:0];
}

@end
