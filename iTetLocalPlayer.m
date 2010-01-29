//
//  iTetLocalPlayer.m
//  iTetrinet
//
//  Created by Alex Heinz on 1/28/10.
//

#import "iTetLocalPlayer.h"
#import "iTetBlock.h"
#import "Queue.h"

@implementation iTetLocalPlayer

- (void)dealloc
{
	[currentBlock release];
	[nextBlock release];
	[specialsQueue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (void)addLines:(NSInteger)lines
{
	[self setLinesCleared:([self linesCleared] + lines)];
	[self setLinesSinceLastLevel:([self linesSinceLastLevel] + lines)];
	[self setLinesSinceLastSpecials:([self linesSinceLastSpecials] + lines)];
}

@synthesize currentBlock;
@synthesize nextBlock;
@synthesize specialsQueue;
@synthesize linesCleared;
@synthesize linesSinceLastLevel;
@synthesize linesSinceLastSpecials;

@end
