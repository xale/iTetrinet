//
//  NSAttributedString+Convenience.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/15/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "NSAttributedString+Convenience.h"

@implementation NSAttributedString (Convenience)

+ (id)attributedStringWithString:(NSString*)string
{
	return [[[self alloc] initWithString:string] autorelease];
}

+ (id)attributedStringWithAttributedString:(NSAttributedString*)attributedString
{
	return [[[self alloc] initWithAttributedString:attributedString] autorelease];
}

+ (id)attributedStringWithString:(NSString*)string
					  attributes:(NSDictionary*)attributes
{
	return [[[self alloc] initWithString:string
							  attributes:attributes] autorelease];
}

@end
