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
	contents = [object retain];
	
	return self;
}

- (void)dealloc
{
	[contents release];
	[next release];
	
	[super dealloc];
}

@synthesize contents;
@synthesize next;

@end
