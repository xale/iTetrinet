//
//  Node.h
//
//  Created by Alex Heinz on 6/9/09.
//

#import <Cocoa/Cocoa.h>


@interface Node : NSObject
{
	id contents;
	Node* next;
}

+ (id)nodeWithContents:(id)object;
- (id)initWithContents:(id)object;

@property (readwrite, retain) id contents;
@property (readwrite, retain) Node* next;

@end
