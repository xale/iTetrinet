//
//  iTetLocalFieldView.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/28/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//
// A BoardView subclass that also draws the active (falling) block and accepts player input. Used only for the local player's board.
//

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

@property (readwrite, nonatomic, retain) iTetBlock* block;

@end

@interface NSObject (iTetLocalFieldViewEventDelegate)

- (void)keyPressed:(iTetKeyNamePair*)key
  onLocalFieldView:(iTetLocalFieldView*)fieldView;

@end

