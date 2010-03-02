//
//  NSMutableData+SingleByte.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/10/09.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableData (SingleByte)

- (void)appendByte:(uint8_t)byte;

- (void)insertByte:(uint8_t)byte
		   atIndex:(NSUInteger)index;

@end
