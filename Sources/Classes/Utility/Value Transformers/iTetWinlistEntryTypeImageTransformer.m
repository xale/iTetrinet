//
//  iTetWinlistEntryTypeImageTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/11/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetWinlistEntryTypeImageTransformer.h"

NSString* const iTetWinlistEntryTypeImageTransformerName = @"TetrinetWinlistEntryTypeImageTransformer";

@implementation iTetWinlistEntryTypeImageTransformer

+ (Class)transformedValueClass
{
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

NSString* const iTetTeamWinlistEntryImageName =		@"NSEveryone";
NSString* const iTetPlayerWinlistEntryImageName =	@"NSUser";

- (id)transformedValue:(id)value
{
	// Check that the value to transform is an NSNumber or subclass thereof
	if (![value isKindOfClass:[NSNumber class]])
		return nil;
	
	// Get the boolean value
	BOOL isTeam = [value boolValue];
	
	// Return the appropriate image
	if (isTeam)
		return [NSImage imageNamed:iTetTeamWinlistEntryImageName];
	
	return [NSImage imageNamed:iTetPlayerWinlistEntryImageName];
}

@end
