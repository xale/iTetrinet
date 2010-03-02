//
//  iTetSpecialNameTransformer.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/15/09.
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetSpecialNameTransformerName;

@interface iTetSpecialNameTransformer : NSValueTransformer
{
	
}

// Overrides
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
// No reverse transformation

@end
