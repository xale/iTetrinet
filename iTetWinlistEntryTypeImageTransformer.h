//
//  iTetWinlistEntryTypeImageTransformer.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/11/10.
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetWinlistEntryTypeImageTransformerName;

@interface iTetWinlistEntryTypeImageTransformer : NSValueTransformer
{
	
}

// Overrides
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
// No reverse transformation

@end
