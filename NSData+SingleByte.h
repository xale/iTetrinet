//
//  NSData+SingleByte.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/10/09.
//

#import <Cocoa/Cocoa.h>

@interface NSData (SingleByte)

// Returns an autoreleased NSData object containing the specified byte
+ (id)dataWithByte:(uint8_t)byte;

// Returns an autoreleased NSData object containing the receiver's bytes plus the specified byte a the end
- (NSData*)dataByAppendingByte:(uint8_t)byte;

// Returns the index of the first occurrence of the specified byte in the receiver, or NSNotFound if the byte is not present in the data
- (NSUInteger)indexOfByte:(uint8_t)byte;

@end

@interface NSMutableData (SingleByte)

// Appends the specified byte to the end of the receiver's bytes
- (void)appendByte:(uint8_t)byte;

// Inserts the specified byte in the receiver's bytes at the specified index, shifting the following bytes
- (void)insertByte:(uint8_t)byte
		   atIndex:(NSUInteger)index;

@end
