//
//  iTetIntegerNotFoundTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/9/11.
//  Copyright 2011 Indie Pennant Software. All rights reserved.
//

#import "iTetIntegerNotFoundTransformer.h"

NSString* const iTetIntegerNotFoundTransformerName =	@"iTetIntegerNotFoundTransformer";

@implementation iTetIntegerNotFoundTransformer

#pragma mark -
#pragma mark Convenience

+ (id)valueTransformer
{
	return [[[self alloc] init] autorelease];
}

+ (NSString*)valueTransformerName
{
	return iTetIntegerNotFoundTransformerName;
}

#pragma mark -
#pragma mark Overrides

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

NSString* const iTetIntegerNotFoundPlaceholder =	@"?";

- (id)transformedValue:(id)value
{
	// Check that the input value is a number
	if (![value isKindOfClass:[NSNumber class]])
		return iTetIntegerNotFoundPlaceholder;
	
	// Retrieve the integer value
	NSInteger integerValue = [(NSNumber*)value integerValue];
	
	// If the value is a "not found" placeholder, return a placeholder string
	if (integerValue == NSNotFound)
		return iTetIntegerNotFoundPlaceholder;
	
	// Return the value as a string
	return [NSString localizedStringWithFormat:@"%d", integerValue];
}

@end
