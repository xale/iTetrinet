//
//  Queue.h
//
//  Created by Alex Heinz on 6/9/09.
//

#import <Cocoa/Cocoa.h>

@class Node;

@interface Queue : NSObject
{
	NSUInteger count;
	Node* head;
	Node* tail;
}

- (void)enqueueObject:(id)object;
- (id)dequeueFirstObject;
- (void)removeAllObjects;

- (id)firstObject;
- (id)lastObject;
- (NSArray*)allObjects;
- (NSUInteger)count;

@end
