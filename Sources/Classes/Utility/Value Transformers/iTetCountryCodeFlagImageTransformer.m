//
//  iTetCountryCodeFlagImageTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/9/11.
//  Copyright 2011 Indie Pennant Software. All rights reserved.
//

#import "iTetCountryCodeFlagImageTransformer.h"


NSString* const iTetCountryCodeFlagImageTransformerName =	@"iTetCountryCodeFlagImageTransformer";

@implementation iTetCountryCodeFlagImageTransformer

+ (id)valueTransformer
{
	return [[[self alloc] init] autorelease];
}

+ (NSString*)valueTransformerName
{
	return iTetCountryCodeFlagImageTransformerName;
}

+ (Class)transformedValueClass
{
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	// Check that the input value is a string
	if (![value isKindOfClass:[NSString class]])
		return nil;
	
	// Treat the input value as a string containing a country code possibly corresponding to the name of a flag image in the resources bundle
	return [NSImage imageNamed:(NSString*)value];
}

@end
