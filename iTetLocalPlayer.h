//
//  iTetLocalPlayer.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/6/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetPlayer.h"
#import "iTetSpecials.h"

@class Queue;
@class iTetBlock;

@interface iTetLocalPlayer : iTetPlayer
{
	iTetBlock* currentBlock;
	iTetBlock* nextBlock;
	
	Queue* specialsQueue;
	NSUInteger queueSize;
}

@property (readwrite, retain) iTetBlock* currentBlock;
@property (readwrite, retain) iTetBlock* nextBlock;

- (void)enqueueSpecial:(iTetSpecialType)special;
- (iTetSpecialType)dequeueSpecial;
- (iTetSpecialType)activeSpecial;
- (void)trimSpecialsQueue;
@property (readwrite, retain) Queue* specialsQueue;
@property (readwrite, assign) NSUInteger queueSize;

@end
