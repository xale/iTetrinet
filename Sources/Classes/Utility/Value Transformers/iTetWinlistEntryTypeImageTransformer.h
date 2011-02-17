//
//  iTetWinlistEntryTypeImageTransformer.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/11/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetWinlistEntryTypeImageTransformerName;

@interface iTetWinlistEntryTypeImageTransformer : NSValueTransformer

+ (id)valueTransformer;
+ (NSString*)valueTransformerName;

// Overrides
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
// No reverse transformation

@end
