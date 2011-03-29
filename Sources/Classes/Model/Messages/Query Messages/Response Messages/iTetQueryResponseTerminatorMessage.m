//
//  iTetQueryResponseTerminatorMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/19/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetQueryResponseTerminatorMessage.h"

NSString* const iTetQueryResponseTerminatorMessageContents =	@"+OK";

@implementation iTetQueryResponseTerminatorMessage

- (id)initWithMessageTokens:(NSArray*)messageTokens
{
	if (!(self = [super initWithMessageTokens:messageTokens]))
		return nil;
	
	// Check the length of the list of tokens, and that the contents are as expected
	if (([messageTokens count] != iTetQueryResponseTerminatorMessageTokenCount) || ![[messageTokens objectAtIndex:0] isEqualToString:iTetQueryResponseTerminatorMessageContents])
	{
		[self release];
		return nil;
	}
	
	// Valid query-response terminator
	return self;
}

- (NSString*)messageContents
{
	return iTetQueryResponseTerminatorMessageContents;
}

@end
