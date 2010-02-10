//
//  iTetAttributeRangePair.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/9/10.
//

#import <Cocoa/Cocoa.h>


@interface iTetAttributeRangePair : NSObject
{
	NSDictionary* attribute;
	NSRange range;
}

+ (id)pairWithAttribute:(NSDictionary*)attr
    beginningAtLocation:(NSUInteger)location;
- (id)initWithAttribute:(NSDictionary*)attr
    beginningAtLocation:(NSUInteger)location;

- (void)closeRangeAtIndex:(NSUInteger)closeLocation;

@property (readonly) NSDictionary* attribute;
@property (readonly) NSRange range;

@end
