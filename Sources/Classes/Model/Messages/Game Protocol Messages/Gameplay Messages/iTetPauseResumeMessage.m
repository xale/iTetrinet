//
//  iTetPauseResumeMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPauseResumeMessage.h"

NSString* const iTetPauseResumeMessageTag =	@"pause";

@implementation iTetPauseResumeMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat the second token as the (paused/resumed) state of the game
	pauseState = [[tokens objectAtIndex:1] intValue];
	
	return self;
}

+ (id)messageWithPauseState:(iTetPauseResumeState)state
{
	return [[[self alloc] initWithPauseState:state] autorelease];
}

- (id)initWithPauseState:(iTetPauseResumeState)state
{
	if (!(self = [super init]))
		return nil;
	
	pauseState = state;
	
	return self;
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	// Override to add message payload to outgoing messages
	return [NSString stringWithFormat:@"%@ %d", iTetPauseResumeMessageTag, [self pauseState]];
}

#pragma mark -
#pragma mark Accessors

@synthesize pauseState;

@end
