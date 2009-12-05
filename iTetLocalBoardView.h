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
	
}

- (iTetLocalPlayer*)ownerAsLocalPlayer;

@end
