//
//  iTetGameVersionTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/10/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGameVersionTransformer.h"
#import "iTetServerInfo.h"

NSString* const iTetGameVersionTransformerName =	@"TetrinetGameVersionTransformer";

@implementation iTetGameVersionTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

#define iTetUnknownGameVersionName	NSLocalizedStringFromTable(@"Unknown Game Version", @"ServerInfo", @"Placeholder string for names of unfamiliar tetrinet game versions (i.e., not 1.13 or 1.14)")

- (id)transformedValue:(id)value
{
	// Check that the value to transform is an NSNumber or subclass thereof
	if (![value isKindOfClass:[NSNumber class]])
		return iTetUnknownGameVersionName;
	
	// Get the integer value, and cast to the version enum type
	iTetGameVersion version = (iTetGameVersion)[value intValue];
	
	// Return the appropriate string representation
	switch (version)
	{
		case version113:
			return iTet113GameVersionName;
		case version114:
			return iTet114GameVersionName;
	}
	
	// Unknown game version (unlikely to happen)
	return iTetUnknownGameVersionName;
}

- (id)reverseTransformedValue:(id)value
{
	// Check that the value to transform is an NSString or subclass
	if (![value isKindOfClass:[NSString class]])
		return [NSNumber numberWithInt:0];
	
	// Determine which game version the string corresponds to
	if ([value isEqualToString:iTet113GameVersionName])
		return [NSNumber numberWithInt:version113];
	if ([value isEqualToString:iTet114GameVersionName])
		return [NSNumber numberWithInt:version114];
	
	// Unkown game version (unlikely to happen)
	return [NSNumber numberWithInt:0];
}

@end
