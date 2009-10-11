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

- (id)initWithNumber:(int)number;

@property (readwrite, retain) iTetBlock* currentBlock;
@property (readwrite, retain) iTetBlock* nextBlock;

- (void)enqueueSpecial:(iTetSpecialType)special;
- (iTetSpecialType)dequeueSpecial;

@property (readonly) Queue* specialsQueue;
@property (readwrite, assign) NSUInteger queueSize;

@end
