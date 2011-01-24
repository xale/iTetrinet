//
//  iTetGameVersionTransformer.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/10/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetGameVersionTransformerName;

@interface iTetGameVersionTransformer : NSValueTransformer

// Overrides
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;

@end
