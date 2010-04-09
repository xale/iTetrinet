//
//  iTetGameStateDescriptionTransformer.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetGameStateDescriptionTransformerName;

@interface iTetGameStateDescriptionTransformer : NSValueTransformer

// Overrides
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
// No reverse transformation

@end
