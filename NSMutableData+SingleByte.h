//
//  NSMutableData+SingleByte.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/10/09.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableData (SingleByte)

// Appends the specified byte to the end of the receiver's bytes
- (void)appendByte:(uint8_t)byte;

// Inserts the specified byte in the receiver's bytes at the specified index, shifting the following bytes
- (void)insertByte:(uint8_t)byte
		   atIndex:(NSUInteger)index;

@end
