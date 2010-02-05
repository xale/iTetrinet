//
//  iTetBlock+Drawing.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetBlock.h"

@class iTetTheme;

@interface iTetBlock (Drawing)

- (NSImage*)imageWithSize:(NSSize)size
			  theme:(iTetTheme*)theme;

- (NSImage*)previewImageWithTheme:(iTetTheme *)theme;

@end
