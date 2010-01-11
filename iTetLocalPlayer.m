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

- (void)setSpecialsQueue:(Queue*)newSpecialsQueue
{
	// Wrap in KVC notifications
	[self willChangeValueForKey:@"specialsQueue"];
	
	// Release the old queue
	[specialsQueue release];
	
	// Assign the new queue
	specialsQueue = [newSpecialsQueue retain];
	
	// End wrap
	[self didChangeValueForKey:@"specialsQueue"];
	
	// Check that new queue size does not exceed limit
	// Note that the "trim" operation will call this method again if changes are
	// necessary, so this check is deliberately placed outside the KVC calls
	if ([specialsQueue count] > [self queueSize])
		[self trimSpecialsQueue];
}

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
	iTetSpecialType special = (iTetSpecialType)[[specialsQueue dequeueFirstObject] intValue];
	
	// Return the dequeued special
	return special;
}
- (iTetSpecialType)activeSpecial
{
	// Check that there are specials in the queue
	if ([specialsQueue count] == 0)
		return invalidSpecial;
	
	// Return the first special in the queue (do not dequeue)
	return (iTetSpecialType)[[specialsQueue firstObject] intValue];
}
- (void)trimSpecialsQueue
{
	// Move 'queueSize' objects from the existing queue to a new one
	Queue* newQueue = [[Queue alloc] init];
	for (int i = 0; i < queueSize; i++)
		[newQueue enqueueObject:[[self specialsQueue] dequeueFirstObject]];
	
	// Replace the old queue with the new one
	[self setSpecialsQueue:newQueue];
}
@synthesize specialsQueue;

- (void)setQueueSize:(NSUInteger)size
{
	// Change the queue size
	queueSize = size;
	
	// Check if the queue contains more items than the new queueSize
	if ([[self specialsQueue] count] > queueSize)
		[self trimSpecialsQueue];
}
@synthesize queueSize;

@end
