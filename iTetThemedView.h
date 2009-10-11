//
//  iTetThemedView.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/13/09.
//
// An abstract NSView subclass that retains a reference to a theme, used by
// subclasses for drawing backgrounds, blocks, and specials; and holds a pointer
// to the player who "owns" the view.

#import <Cocoa/Cocoa.h>
#import "iTetTheme.h"
#import "iTetPlayer.h"

@interface iTetThemedView : NSView
{
	iTetTheme* theme;
	iTetPlayer* owner;
}

@property (readwrite, retain) iTetTheme* theme;
@property (readwrite, assign) iTetPlayer* owner;

@end
