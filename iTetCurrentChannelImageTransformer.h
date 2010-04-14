//
//  iTetCurrentChannelImageTransformer.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/14/10.
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetCurrentChannelImageTransformerName;

@interface iTetCurrentChannelImageTransformer : NSValueTransformer

// Overrides
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
// No reverse transformation

@end
