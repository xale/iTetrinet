//
//  iTetLocalPlayer.h
//  iTetrinet
//
//  Created by Alex Heinz on 1/28/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetPlayer.h"

@class iTetBlock;
@class iTetSpecial;

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
- (void)addSpecialToQueue:(iTetSpecial*)special;
- (void)dequeueNextSpecial;

@property (readwrite, retain) iTetBlock* currentBlock;
@property (readwrite, retain) iTetBlock* nextBlock;
@property (readwrite, nonatomic, retain) NSMutableArray* specialsQueue;
@property (readonly) iTetSpecial* nextSpecial;
@property (readwrite, assign) NSInteger linesCleared;
@property (readwrite, assign) NSInteger linesSinceLastLevel;
@property (readwrite, assign) NSInteger linesSinceLastSpecials;

@end
