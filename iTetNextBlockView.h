//
//  iTetNextBlockView.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//
// A ThemedView subclass that previews the next block for the local player.

#import <Cocoa/Cocoa.h>
#import "iTetThemedView.h"
#import "iTetLocalPlayerView.h"

@interface iTetNextBlockView : iTetThemedView <iTetLocalPlayerView>
{
	
}

- (iTetLocalPlayer*)ownerAsLocalPlayer;

@end
