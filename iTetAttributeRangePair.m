//
//  iTetAttributeRangePair.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/9/10.
//

#import "iTetAttributeRangePair.h"

@implementation iTetAttributeRangePair

+ (id)pairWithAttribute:(NSDictionary*)attr
    beginningAtLocation:(NSUInteger)location
{
	return [[[self alloc] initWithAttribute:attr
				  beginningAtLocation:location] autorelease];
}

- (id)initWithAttribute:(NSDictionary*)attr
    beginningAtLocation:(NSUInteger)location
{
	attribute = [attr retain];
	range.location = location;
	
	return self;
}

- (void)dealloc
{
	[attribute release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (void)closeRangeAtIndex:(NSUInteger)closeLocation
{
	range.length = (closeLocation - range.location);
}

@synthesize attribute;
@synthesize range;

@end
