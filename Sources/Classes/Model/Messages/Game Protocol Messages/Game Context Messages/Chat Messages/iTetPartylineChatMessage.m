//
//  iTetPartylineChatMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/27/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPartylineChatMessage.h"

#import "NSArray+Subranges.h"
#import "NSAttributedString+TetrinetTextAttributes.h"

NSString* const iTetPartylineChatMessageTag =	@"pline";

@implementation iTetPartylineChatMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat second token as the sender player's number
	senderPlayerNumber = [[tokens objectAtIndex:1] integerValue];
	
	// Treat the remaining tokens (if any) as the chat message
	if ([tokens count] > 2)
	{
		NSString* rawChatString = [[tokens subarrayFromIndex:2] componentsJoinedByString:@" "];
		chatContents = [[NSAttributedString alloc] initWithPlineMessageContents:rawChatString];
	}
	
	return self;
}

+ (id)messageWithChatContents:(NSAttributedString*)contents
					   sender:(NSInteger)playerNumber
{
	return [[[self alloc] initWithChatContents:contents
										sender:playerNumber] autorelease];
}

- (id)initWithChatContents:(NSAttributedString*)contents
					sender:(NSInteger)playerNumber
{
	if (!(self = [super init]))
		return nil;
	
	senderPlayerNumber = playerNumber;
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
	return [NSString stringWithFormat:@"%@ %ld %@", [self messageTag], (long)[self senderPlayerNumber], [[self chatContents] plineMessageString]];
}

#pragma mark -
#pragma mark Accessors

- (NSString*)messageTag
{
	return iTetPartylineChatMessageTag;
}

@synthesize senderPlayerNumber;
@synthesize chatContents;

@end
