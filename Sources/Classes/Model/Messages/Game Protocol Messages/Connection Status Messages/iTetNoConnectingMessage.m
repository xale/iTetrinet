//
//  iTetNoConnectingMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNoConnectingMessage.h"
#import "NSArray+Subranges.h"

NSString* const iTetNoConnectingMessageTag =	@"noconnecting";

@implementation iTetNoConnectingMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat all tokens beyond the first, if present, as the reason message
	if ([tokens count] > 1)
		reason = [[[tokens subarrayFromIndex:1] componentsJoinedByString:@" "] retain];
	
	return self;
}

- (id)initWithReason:(NSString*)reasonMessage
{
	if (!(self = [super init]))
		return nil;
	
	reason = [reasonMessage copy];
	
	return self;
}

- (void)dealloc
{
	[reason release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	if ([[self reason] length] > 0)
		return [NSString stringWithFormat:@"%@ %@", iTetNoConnectingMessageTag, [self reason]];
	
	return iTetNoConnectingMessageTag;
}

#pragma mark -
#pragma mark Accessors

@synthesize reason;

@end
