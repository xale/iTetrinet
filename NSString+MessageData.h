//
//  NSString+MessageData.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>

@interface NSString (MessageData)

// Returns the representation of the data provided from a message as an NSString; the data does _not_ need to be null-terminated
+ (id)stringWithMessageData:(NSData*)data;

// Returns an NSData object containing the receiver's contents encoded in a format suitable for sending in a message
- (NSData*)messageData;

@end
