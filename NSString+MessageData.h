//
//  NSString+MessageData.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

#define iTetDefaultStringEncoding			NSUTF8StringEncoding
#define iTetStandardTetrinetStringEncoding	NSWindowsCP1252StringEncoding
#define iTetFallbackISOStringEncoding		NSISOLatin1StringEncoding

@interface NSString (MessageData)

// Returns the representation of the data provided from a message as an autoreleased NSString; the data does _not_ need to be null-terminated
+ (id)stringWithMessageData:(NSData*)messageData;

// Returns an autoreleased NSString containing the specified data interpreted using the specified encoding; the data need not be null-terminated
+ (id)stringWithData:(NSData*)data
			encoding:(NSStringEncoding)encoding;

// Returns an NSData object containing the receiver's contents encoded in a format suitable for sending in a message
- (NSData*)messageData;

@end
