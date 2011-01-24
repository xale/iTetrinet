//
//  NSString+QuotedComponents.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/30/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface NSString (QuotedComponents)

// Returns an array containing the components of the reciever separated by the specified string, with quoted token ranges counting as one component; optionally strips the quotation marks
// The reciever must contain at most one level of balanced quotation, (this method does not handle escaped quotes) and the separator cannot be nil or contain quotation marks
- (NSArray*)quotedComponentsSeparatedByString:(NSString*)sep
								  stripQuotes:(BOOL)strip;

@end
