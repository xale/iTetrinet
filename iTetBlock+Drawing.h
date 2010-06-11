//
//  iTetBlock+Drawing.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetBlock.h"

@class iTetTheme;

@interface iTetBlock (Drawing)

- (NSImage*)imageWithSize:(NSSize)size
					theme:(iTetTheme*)theme;

- (NSImage*)previewImageWithTheme:(iTetTheme *)theme;

@end
