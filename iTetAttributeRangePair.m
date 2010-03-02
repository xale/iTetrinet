//
//  iTetAttributeRangePair.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/9/10.
//

#import "iTetAttributeRangePair.h"

@implementation iTetAttributeRangePair

+ (id)pairWithAttributeType:(uint8_t)attr
					  value:(NSDictionary*)value
		beginningAtLocation:(NSUInteger)location
{
	return [[[self alloc] initWithAttributeType:attr
										  value:value
							beginningAtLocation:location] autorelease];
}

- (id)initWithAttributeType:(uint8_t)attr
					  value:(NSDictionary*)value
		beginningAtLocation:(NSUInteger)location
{
	attributeType = attr;
	attributeValue = [value retain];
	range.location = location;
	
	return self;
}

- (void)dealloc
{
	[attributeValue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Comparators

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[self class]])
	{
		iTetAttributeRangePair* otherPair = (iTetAttributeRangePair*)object;
		
		return ([self attributeType] == [otherPair attributeType]);
	}
	
	return NO;
}

#pragma mark -
#pragma mark Accessors

- (void)setLastIndexInRange:(NSUInteger)lastIndex
{
	range.length = (lastIndex - range.location) + 1;
}

@synthesize attributeType;
@synthesize attributeValue;
@synthesize range;

@end
