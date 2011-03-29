//
//  iTetGameChatMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/27/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGameChatMessage.h"
#import "NSArray+Subranges.h"

NSString* const iTetGameChatMessageTag =	@"gmsg";

@implementation iTetGameChatMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat all tokens beyond the first as the contents of the chat message
	chatContents = [[[tokens subarrayFromIndex:1] componentsJoinedByString:@" "] retain];
	
	return self;
}

+ (id)messageWithChatContents:(NSString*)contents
{
	return [[[self alloc] initWithChatContents:contents] autorelease];
}

- (id)initWithChatContents:(NSString*)contents
{
	if (!(self = [super init]))
		return nil;
	
	chatContents = [contents copy];
	
	return self;
}

- (void)dealloc
{
	[chatContents release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %@", iTetGameChatMessageTag, [self chatContents]];
}

#pragma mark -
#pragma mark Accessors

@synthesize chatContents;

@end
