//
//  iTetSpecialNameTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/15/09.
//

#import "iTetSpecialNameTransformer.h"
#import "iTetSpecials.h"

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
	
	// Get the integer value; cast to the enum type iTetSpecialType
	iTetSpecialType type = (iTetSpecialType)[value intValue];
	
	// Return the appropriate string representation
	return iTetNameForSpecialType(type);
}

@end
