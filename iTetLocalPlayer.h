//
//  iTetLocalPlayer.h
//  iTetrinet
//
//  Created by Alex Heinz on 1/28/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetPlayer.h"
#import "iTetSpecials.h"

@class iTetBlock;
@class Queue;

@interface iTetLocalPlayer : iTetPlayer
{
	iTetBlock* currentBlock;
	iTetBlock* nextBlock;
	NSMutableArray* specialsQueue;
	
	NSInteger linesCleared;
	NSInteger linesSinceLastLevel;
	NSInteger linesSinceLastSpecials;
}

- (void)addLines:(NSInteger)lines;
- (void)resetLinesCleared;
- (void)addSpecialToQueue:(NSNumber*)special;
- (iTetSpecialType)dequeueNextSpecial;

@property (readwrite, retain) iTetBlock* currentBlock;
@property (readwrite, retain) iTetBlock* nextBlock;
@property (readwrite, retain) NSMutableArray* specialsQueue;
@property (readonly) NSNumber* nextSpecial;
@property (readwrite, assign) NSInteger linesCleared;
@property (readwrite, assign) NSInteger linesSinceLastLevel;
@property (readwrite, assign) NSInteger linesSinceLastSpecials;

@end
