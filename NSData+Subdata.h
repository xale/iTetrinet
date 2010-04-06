//
//  NSData+Subdata.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>

@interface NSData (Subdata)

// Returns an NSData object containing the bytes of the receiver up to and excluding the specified index.
- (NSData*)subdataToIndex:(NSUInteger)index;

// Returns an NSData object containing the bytes of the receiver from the specified index to the end, inclusive.
- (NSData*)subdataFromIndex:(NSUInteger)index;

@end
