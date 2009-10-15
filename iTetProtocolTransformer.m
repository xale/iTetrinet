//
//  iTetProtocolTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/25/09.
//

#import "iTetProtocolTransformer.h"
#import "iTetServerInfo.h"

NSString* const tetrinetProtocolString = @"Tetrinet";
NSString* const tetrifastProtocolString = @"Tetrifast";
NSString* const unknownProtocolString = @"Unknown Protocol";

@implementation iTetProtocolTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(id)value
{
	// Check that the value to transform is an NSNumber or subclass thereof
	if (![value isKindOfClass:[NSNumber class]])
		return unknownProtocolString;
	
	// Get the integer value; cast to the enum type iTetProtocolType
	iTetProtocolType protocol = (iTetProtocolType)[value intValue];
	
	// Return the appropriate string representation
	switch (protocol)
	{
		case tetrinetProtocol:
			return tetrinetProtocolString;
		case tetrifastProtocol:
			return tetrifastProtocolString;
	}
	
	// Unknown protocol (unlikely to happen)
	return unknownProtocolString;
}

- (id)reverseTransformedValue:(id)value
{
	// Check that the value to transform is an NSString or subclass
	if (![value isKindOfClass:[NSString class]])
		return [NSNumber numberWithInt:0];
	
	// Determine which protocol the string corresponds to
	if ([value isEqualToString:tetrinetProtocolString])
		return [NSNumber numberWithInt:(int)tetrinetProtocol];
	if ([value isEqualToString:tetrifastProtocolString])
		return [NSNumber numberWithInt:(int)tetrifastProtocol];
	
	// Unkown protocol (unlikely to happen)
	return [NSNumber numberWithInt:0];
}

@end
