//
//  NSAttributedString+TetrinetTextAttributes.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/20/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (TetrinetTextAttributes)

+ (id)attributedStringWithPlineMessageContents:(NSString*)messageContents;
- (id)initWithPlineMessageContents:(NSString*)messageContents;

- (NSString*)plineMessageString;

@end
