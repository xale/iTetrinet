//
//  NSAttributedString+Convenience.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/15/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (Convenience)

+ (id)attributedStringWithString:(NSString*)string;
+ (id)attributedStringWithAttributedString:(NSAttributedString*)attributedString;
+ (id)attributedStringWithString:(NSString*)string
					  attributes:(NSDictionary*)attributes;

@end
