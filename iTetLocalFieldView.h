//
//  iTetLocalFieldView.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/28/09.
//
// A BoardView subclass that also draws the active (falling) block and accepts
// player input. Used only for the local player's board.

#import <Cocoa/Cocoa.h>
#import "iTetFieldView.h"

@class iTetKeyNamePair;
@class iTetBlock;

@interface iTetLocalFieldView : iTetFieldView
{
	iTetBlock* block;
	
	IBOutlet id eventDelegate;
}

- (void)keyEvent:(NSEvent*)keyEvent;

@property (readwrite, retain) iTetBlock* block;

@end

@interface NSObject (iTetLocalFieldViewEventDelegate)

- (void)keyPressed:(iTetKeyNamePair*)key
  onLocalFieldView:(iTetLocalFieldView*)fieldView;

@end

