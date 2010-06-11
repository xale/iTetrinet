//
//  iTetProtocolTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/25/09.
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

NSString* const iTetTetrinetProtocolName =	@"Tetrinet";
NSString* const iTetTetrifastProtocolName =	@"Tetrifast";
#define iTetUnknownProtocolName	NSLocalizedStringFromTable(@"Unknown Protocol", @"ServerInfo", @"Placeholder string for names of unfamiliar tetrinet protocols")

- (id)transformedValue:(id)value
{
	// Check that the value to transform is an NSNumber or subclass thereof
	if (![value isKindOfClass:[NSNumber class]])
		return iTetUnknownProtocolName;
	
	// Get the integer value, and cast to the protocol enum type
	iTetProtocolType protocol = (iTetProtocolType)[value intValue];
	
	// Return the appropriate string representation
	switch (protocol)
	{
		case tetrinetProtocol:
			return iTetTetrinetProtocolName;
		case tetrifastProtocol:
			return iTetTetrifastProtocolName;
	}
	
	// Unknown protocol (unlikely to happen)
	return iTetUnknownProtocolName;
}

- (id)reverseTransformedValue:(id)value
{
	// Check that the value to transform is an NSString or subclass
	if (![value isKindOfClass:[NSString class]])
		return [NSNumber numberWithInt:0];
	
	// Determine which protocol the string corresponds to
	if ([value isEqualToString:iTetTetrinetProtocolName])
		return [NSNumber numberWithInt:(int)tetrinetProtocol];
	if ([value isEqualToString:iTetTetrifastProtocolName])
		return [NSNumber numberWithInt:(int)tetrifastProtocol];
	
	// Unkown protocol (unlikely to happen)
	return [NSNumber numberWithInt:0];
}

@end
