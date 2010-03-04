//
//  iTetAttributeRangePair.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/9/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetTextAttributes.h"

@interface iTetAttributeRangePair : NSObject
{
	uint8_t attributeType;
	id attributeValue;
	NSRange range;
}

+ (id)pairWithAttributeType:(uint8_t)attr
					  value:(id)value
		beginningAtLocation:(NSUInteger)location;
- (id)initWithAttributeType:(uint8_t)attr
					  value:(id)value
		beginningAtLocation:(NSUInteger)location;

- (void)setLastIndexInRange:(NSUInteger)lastIndex;

@property (readonly) uint8_t attributeType;
@property (readonly) id attributeValue;
@property (readonly) NSRange range;

@end
