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

+ (id)queue;

- (void)enqueueObject:(id)object;
- (id)dequeueFirstObject;
- (void)removeAllObjects;

@property (readonly) id firstObject;
@property (readonly) id lastObject;
@property (readonly) NSArray* allObjects;
@property (readonly) NSUInteger count;

@end
