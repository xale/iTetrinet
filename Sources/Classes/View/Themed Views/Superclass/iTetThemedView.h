//
//  iTetThemedView.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/13/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//
// An abstract NSView subclass that retains a reference to a theme, used by subclasses for drawing backgrounds, blocks, and specials
//

#import <Cocoa/Cocoa.h>
#import "iTetTheme.h"
#import "iTetPlayer.h"

@interface iTetThemedView : NSView
{
	iTetTheme* theme;
}

@property (readwrite, nonatomic, retain) iTetTheme* theme;

@end
