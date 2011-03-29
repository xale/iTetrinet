//
//  iTetMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@implementation iTetMessage

- (id)init
{
	return [self initWithMessageTokens:nil];
}

+ (id)messageWithMessageTokens:(NSArray*)tokens
{
	return [[[self alloc] initWithMessageTokens:tokens] autorelease];
}

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super init]))
		return nil;
	
	// Abstract class; throw an exception on instantiation
	if ([self isMemberOfClass:[iTetMessage class]])
	{
		[self doesNotRecognizeSelector:_cmd];
		[self release];
		return nil;	
	}
	
	return self;
}

- (NSString*)messageContents
{
	// Abstract method; throw an exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end
