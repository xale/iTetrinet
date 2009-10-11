//
//  Queue.m
//
//  Created by Alex Heinz on 6/9/09.
//

#import "Queue.h"
#import "Node.h"

@implementation Queue

- (void)dealloc
{
	[self removeAllObjects];
	
	[super dealloc];
}

- (void)enqueueObject:(id)object
{
	// Wrap the object in a new node (object will be retained)
	Node* newNode = [Node nodeWithContents:object];
	
	// Check: is the queue non-empty?
	if (count > 0)
	{
		// Point the current tail at the new node (will be retained)
		[tail setNext:newNode];
		
		// Make the new node the new tail
		tail = newNode;
	}
	else
	{
		// Queue is empty; the new node is both the head and tail
		head = [newNode retain];
		tail = newNode;
	}
	
	// Increment the count of nodes in the queue
	count++;
}

- (id)dequeueFirstObject
{
	// Check that we have objects in the queue
	if (count == 0)
		return nil;
	
	// Get the first node in the queue
	Node* firstNode = head;
	
	// Get the object out of the first node
	id object = [[firstNode contents] retain];
	
	// Check: is there more than one node in the queue?
	if (count > 1)
	{
		// Advance the head pointer to the next node
		head = [[firstNode next] retain];
	}
	else
	{
		// Last remaining node; set the head and tail pointers to nil
		head = nil;
		tail = nil;
	}
	
	// Release the node
	[firstNode release];
	
	// Decrement the count of nodes
	count--;
	
	// Return the object removed from the first node
	return [object autorelease];
}

- (void)removeAllObjects
{
	// Only the first node is retained, so releasing it will recursively
	// release all the other nodes in the queue
	[head release];
	
	// nil the head and tail pointers
	head = nil;
	tail = nil;
	
	// Reset the count
	count = 0;
}

- (id)firstObject
{
	// Simple "peek" operation
	if (count > 0)
		return [head contents];
	
	return nil;
}

- (id)lastObject
{
	if (count > 0)
		return [tail contents];
	
	return nil;
}

- (NSArray*)allObjects
{
	// Create a mutable array
	NSMutableArray* output = [NSMutableArray arrayWithCapacity:count];
	
	// Fill the array with the contents of the queue
	Node* currentNode;
	for (currentNode = head; currentNode != nil; currentNode = [currentNode next])
	{
		[output addObject:[currentNode contents]];
	}
	
	return output;
}

- (NSUInteger)count
{
	// Return the number of nodes in the queue
	return count;
}

@end
