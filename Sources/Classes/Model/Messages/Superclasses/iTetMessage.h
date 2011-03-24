//
//  iTetMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface iTetMessage : NSObject

/*!
 Creates and initializes a new message object using a list of space-separated strings read from the network connection.
 @param tokens Data read from the server connection, as a list of strings.
 */
+ (id)messageWithMessageTokens:(NSArray*)tokens;

/*!
 Initializes a new message object using a list of space-separated strings read from the network connection.
 @param tokens Data read from the server connection, as a list of strings.
 */
- (id)initWithMessageTokens:(NSArray*)tokens;

/*!
 Returns a string representation of the receiver suitable for transmission to the server over a network connection.
 */
- (NSString*)messageContents;

@end
