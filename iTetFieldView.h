//
//  iTetFieldView.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//
// A ThemedView subclass used for drawing a player's field (background + blocks)

#import <Cocoa/Cocoa.h>
#import "iTetThemedView.h"

@interface iTetFieldView : iTetThemedView
{
	IBOutlet NSTextField* numberField;
	IBOutlet NSTextField* nicknameField;
}

@end
