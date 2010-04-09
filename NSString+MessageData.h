//
//  NSString+MessageData.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>

#define iTetDefaultStringEncoding	NSUTF8StringEncoding
#define iTetFallbackStringEncoding	NSWindowsCP1252StringEncoding

@interface NSString (MessageData)

// Returns the representation of the data provided from a message as an autoreleased NSString; the data does _not_ need to be null-terminated
+ (id)stringWithMessageData:(NSData*)messageData;

// Returns an autoreleased NSString containing the specified data interpreted using the specified encoding; the data need not be null-terminated
+ (id)stringWithData:(NSData*)data
			encoding:(NSStringEncoding)encoding;

// Returns an NSData object containing the receiver's contents encoded in a format suitable for sending in a message
- (NSData*)messageData;

@end
