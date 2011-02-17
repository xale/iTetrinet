//
//  iTetIntegerNotFoundTransformer.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/9/11.
//  Copyright 2011 Indie Pennant Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetIntegerNotFoundTransformerName;

@interface iTetIntegerNotFoundTransformer : NSValueTransformer

// Convenience methods
+ (id)valueTransformer;
+ (NSString*)valueTransformerName;

// Required overrides
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;

@end
