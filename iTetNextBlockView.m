//
//  iTetNextBlockView.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetNextBlockView.h"
#import "iTetLocalPlayer.h"
#import "iTetBlock.h"
#import "iTetBlock+Drawing.h"

@implementation iTetNextBlockView

- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	[self addObserver:self
		 forKeyPath:@"owner.nextBlock"
		    options:0
		    context:NULL];
	
	return self;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	// Get the view's owner as a local player
	iTetLocalPlayer* player = [self ownerAsLocalPlayer];
	
	// If we have no owner, we have nothing else to draw
	if (player == nil)
		return;
	
	// Get the player's next block
	iTetBlock* nextBlock = [player nextBlock];
	
	// Check that there is a block to draw
	if (nextBlock == nil)
		return;
	
	// Ask the block to draw itself to an NSImage of this view's size
	NSImage* blockImage = [nextBlock imageWithSize:[self bounds].size
							     theme:[self theme]];
	
	// Draw the image
	[blockImage drawAtPoint:rect.origin
			   fromRect:rect
			  operation:NSCompositeSourceOver
			   fraction:1.0];
}

#pragma mark -
#pragma mark Accessors

- (iTetLocalPlayer*)ownerAsLocalPlayer
{
	if (owner == nil)
		return nil;
	
	if ([owner isKindOfClass:[iTetLocalPlayer class]])
		return (iTetLocalPlayer*)owner;
	
	NSLog(@"Warning: NextBlockView owned by non-local player");
	return nil;
}

- (BOOL)isOpaque
{
	return NO;
}

@end
