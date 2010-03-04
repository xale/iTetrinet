//
//  NSData+Searching.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>

@interface NSData (Searching)

- (NSUInteger)indexOfByte:(uint8_t)byte;

- (NSData*)subdataToIndex:(NSUInteger)index;
- (NSData*)subdataFromIndex:(NSUInteger)index;

@end
