//
//  iTetNextBlockView.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//
// A ThemedView subclass that previews the next block for the local player.

#import <Cocoa/Cocoa.h>
#import "iTetThemedView.h"

@class iTetBlock;

@interface iTetNextBlockView : iTetThemedView
{
	iTetBlock* block;
}

@property (readwrite, copy) iTetBlock* block;

@end
