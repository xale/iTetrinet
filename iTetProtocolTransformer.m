//
//  iTetProtocolTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/25/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetProtocolTransformer.h"
#import "iTetServerInfo.h"

NSString* const iTetProtocolTransformerName = @"TetrinetProtocolTransformer";

@implementation iTetProtocolTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

NSString* const tetrinetProtocolName =	@"Tetrinet";
NSString* const tetrifastProtocolName =	@"Tetrifast";
NSString* const unknownProtocolName =	@"Unknown Protocol";

- (id)transformedValue:(id)value
{
	// Check that the value to transform is an NSNumber or subclass thereof
	if (![value isKindOfClass:[NSNumber class]])
		return unknownProtocolName;
	
	// Get the integer value, and cast to the protocol enum type
	iTetProtocolType protocol = (iTetProtocolType)[value intValue];
	
	// Return the appropriate string representation
	switch (protocol)
	{
		case tetrinetProtocol:
			return tetrinetProtocolName;
		case tetrifastProtocol:
			return tetrifastProtocolName;
	}
	
	// Unknown protocol (unlikely to happen)
	return unknownProtocolName;
}

- (id)reverseTransformedValue:(id)value
{
	// Check that the value to transform is an NSString or subclass
	if (![value isKindOfClass:[NSString class]])
		return [NSNumber numberWithInt:0];
	
	// Determine which protocol the string corresponds to
	if ([value isEqualToString:tetrinetProtocolName])
		return [NSNumber numberWithInt:(int)tetrinetProtocol];
	if ([value isEqualToString:tetrifastProtocolName])
		return [NSNumber numberWithInt:(int)tetrifastProtocol];
	
	// Unkown protocol (unlikely to happen)
	return [NSNumber numberWithInt:0];
}

@end
