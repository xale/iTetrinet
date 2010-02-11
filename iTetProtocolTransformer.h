//
//  iTetProtocolTransformer.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/25/09.
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetProtocolTransformerName;

@interface iTetProtocolTransformer : NSValueTransformer
{
	
}

// Overrides
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;

@end
