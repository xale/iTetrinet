//
//  iTetThemedView.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/13/09.
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

@property (readwrite, retain) iTetTheme* theme;

@end
