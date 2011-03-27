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

/*!
 Creates and returns a list of tokens in the reciever separated by the specified string, with each quoted run of tokens counting as a single token; optionally strips the quotation marks. The reciever must contain at most one level of balanced quotation (this method does not handle nested or escaped quotation marks.)
 @param sep The separator used to split the receiver; must not be \c nil, and cannot contain quotation marks.
 @param strip If \c YES, any quoted runs will be stripped of their quotation marks before the list of tokens is returned.
 @return A list of tokens, or \c nil if the receiver contains unbalanced quotation marks.
 */
- (NSArray*)quotedComponentsSeparatedByString:(NSString*)sep
								  stripQuotes:(BOOL)strip;

@end
