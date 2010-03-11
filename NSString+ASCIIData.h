//
//  NSString+ASCIIData.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>

@interface NSString (ASCIIData)

// Returns the ASCII-encoded representation of the provided data as an NSString, or nil if the data cannot be encoded as ASCII; 'asciiData' does _not_ need to be null-terminated
+ (id)stringWithASCIIData:(NSData*)asciiData;

@end
