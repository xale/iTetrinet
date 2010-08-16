//
//  iTetSpecialNameTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/15/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetSpecialNameTransformer.h"
#import "NSNumber+iTetSpecials.h"

NSString* const iTetSpecialNameTransformerName = @"TetrinetSpecialNameTransformer";

@implementation iTetSpecialNameTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	// Check that the value to transform is an NSNumber or subclass thereof
	if (![value isKindOfClass:[NSNumber class]])
		return nil;
	
	// Return the appropriate string representation of the special
	NSNumber* specialValue = (NSNumber*)value;
	return [specialValue specialDisplayName];
}

@end
