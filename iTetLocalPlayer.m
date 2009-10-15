//
//  iTetLocalPlayer.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/6/09.
//

#import "iTetLocalPlayer.h"
#import "iTetBlock.h"
#import "Queue.h"

@implementation iTetLocalPlayer

- (id)initWithNumber:(int)number
{
	if (![super initWithNumber:number])
		return nil;
	
	specialsQueue = [[Queue alloc] init];
	
	return self;
}

- (void)dealloc
{
	[currentBlock release];
	[nextBlock release];
	
	[specialsQueue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize currentBlock;
@synthesize nextBlock;

- (void)enqueueSpecial:(iTetSpecialType)special
{
	// Check if there is space to add another special
	if ([specialsQueue count] >= queueSize)
		return;
	
	// Enqueue the special
	[specialsQueue enqueueObject:[NSNumber numberWithInt:(int)special]];
}
- (iTetSpecialType)dequeueSpecial
{
	// Check that there are specials to use
	if ([specialsQueue count] == 0)
		return invalidSpecial;
	
	// Dequeue the first special
	return (iTetSpecialType)[[specialsQueue dequeueFirstObject] intValue];
}
- (iTetSpecialType)activeSpecial
{
	// Check that there are specials in the queue
	if ([specialsQueue count] == 0)
		return invalidSpecial;
	
	// Return the first special in the queue (do not dequeue)
	return (iTetSpecialType)[[specialsQueue firstObject] intValue];
}
@synthesize specialsQueue;

- (void)setQueueSize:(NSUInteger)size
{
	// Change the queueSize
	queueSize = size;
	
	// Check if the queue contains more items than the new queueSize
	if ([specialsQueue count] > queueSize)
	{
		// Move 'queueSize' objects from the existing queue to a new one
		Queue* newQueue = [[Queue alloc] init];
		for (int i = 0; i < queueSize; i++)
			[newQueue enqueueObject:[specialsQueue dequeueFirstObject]];
		
		// Replace the old queue with the new one
		[specialsQueue release];
		specialsQueue = newQueue;
	}
}
@synthesize queueSize;

@end
