//
//  Queue.m
//
//  Created by Alex Heinz on 6/9/09.
//

#import "Queue.h"
#import "Node.h"

@implementation Queue

+ (id)queue
{
	return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
	[self removeAllObjects];
	
	[super dealloc];
}

- (void)enqueueObject:(id)object
{
	// Wrap the object in a new node (object will be retained)
	Node* newNode = [Node nodeWithContents:object];
	
	[self willChangeValueForKey:@"lastObject"];
	[self willChangeValueForKey:@"allObjects"];
	[self willChangeValueForKey:@"count"];
	
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
		[self willChangeValueForKey:@"firstObject"];
		head = [newNode retain];
		[self didChangeValueForKey:@"firstObject"];
		
		tail = newNode;
	}
	
	// Increment the count of nodes in the queue
	count++;
	
	[self didChangeValueForKey:@"count"];
	[self didChangeValueForKey:@"allObjects"];
	[self didChangeValueForKey:@"lastObject"];
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
	
	[self willChangeValueForKey:@"firstObject"];
	[self willChangeValueForKey:@"allObjects"];
	[self willChangeValueForKey:@"count"];
	
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
		[self willChangeValueForKey:@"lastObject"];
		tail = nil;
		[self didChangeValueForKey:@"lastObject"];
	}
	
	// Decrement the count of nodes
	count--;
	
	[self didChangeValueForKey:@"count"];
	[self didChangeValueForKey:@"allObjects"];
	[self didChangeValueForKey:@"firstObject"];
	
	// Release the node
	[firstNode release];
	
	// Return the object removed from the first node
	return [object autorelease];
}

- (void)removeAllObjects
{
	[self willChangeValueForKey:@"firstObject"];
	[self willChangeValueForKey:@"lastObject"];
	[self willChangeValueForKey:@"allObjects"];
	[self willChangeValueForKey:@"count"];
	
	// Only the first node is retained, so releasing it will recursively
	// release all the other nodes in the queue
	[head release];
	
	// nil the head and tail pointers
	head = nil;
	tail = nil;
	
	// Reset the count
	count = 0;
	
	[self didChangeValueForKey:@"count"];
	[self didChangeValueForKey:@"allObjects"];
	[self didChangeValueForKey:@"lastObject"];
	[self didChangeValueForKey:@"firstObject"];
}

#pragma mark -
#pragma mark Properties

- (id)firstObject
{	
	// Simple "peek" operation
	if (head != nil)
		return [head contents];
	
	return nil;
}

- (id)lastObject
{
	if (tail != nil)
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

@synthesize count;

@end
