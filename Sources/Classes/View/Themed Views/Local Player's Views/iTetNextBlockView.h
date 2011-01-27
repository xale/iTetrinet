//
//  iTetNextBlockView.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//
// A ThemedView subclass that previews the next block for the local player.

#import "iTetThemedView.h"

@class iTetBlock;

@interface iTetNextBlockView : iTetThemedView
{
	iTetBlock* block;
}

@property (readwrite, nonatomic, copy) iTetBlock* block;

@end
