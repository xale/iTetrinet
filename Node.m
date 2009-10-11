//
//  Node.m
//
//  Created by Alex Heinz on 6/9/09.
//

#import "Node.h"

@implementation Node

+ (id)nodeWithContents:(id)object
{
	return [[[Node alloc] initWithContents:object] autorelease];
}

- (id)initWithContents:(id)object
{
	[self setContents:object];
	
	return self;
}

- (void)dealloc
{
	[self setContents:nil];
	[self setNext:nil];
	
	[super dealloc];
}

@synthesize contents;
@synthesize next;

@end
