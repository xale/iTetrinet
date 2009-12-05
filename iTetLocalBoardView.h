//
//  iTetLocalBoardView.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/28/09.
//
// A BoardView subclass that also draws the active (falling) block and accepts
// player input. Used only for the local player's board.

#import <Cocoa/Cocoa.h>
#import "iTetBoardView.h"
#import "iTetLocalPlayerView.h"

@interface iTetLocalBoardView : iTetBoardView <iTetLocalPlayerView>
{
	if (![super initWithFrame:frame])
		return nil;
	
	[self addObserver:self
		 forKeyPath:@"owner.currentBlock.rowPos"
		    options:0
		    context:NULL];
	[self addObserver:self
		 forKeyPath:@"owner.currentBlock.colPos"
		    options:0
		    context:NULL];
	[self addObserver:self
		 forKeyPath:@"owner.currentBlock.orientation"
		    options:0
		    context:NULL];
	
	return self;
}

- (iTetLocalPlayer*)ownerAsLocalPlayer;

@end
