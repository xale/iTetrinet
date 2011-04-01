//
//  iTetSpecialMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetSpecialMessage.h"

NSString* const iTetSpecialMessageTag =	@"sb";

@implementation iTetSpecialMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat the second token as the target player number
	targetPlayerNumber = [[tokens objectAtIndex:1] integerValue];
	
	// Treat the third token as the special designation
	specialDesignation = [[tokens objectAtIndex:2] copy];
	
	// Treat the fourth token as the sender player number
	senderPlayerNumber = [[tokens objectAtIndex:3] integerValue];
	
	return self;
}

+ (id)messageWithSender:(NSInteger)senderNumber
				 target:(NSInteger)targetNumber
	 specialDesignation:(NSString*)special
{
	return [[[self alloc] initWithSender:senderNumber
								  target:targetNumber
					  specialDesignation:special] autorelease];
}

- (id)initWithSender:(NSInteger)senderNumber
			  target:(NSInteger)targetNumber
  specialDesignation:(NSString*)special
{
	if (!(self = [super init]))
		return nil;
	
	senderPlayerNumber = senderNumber;
	targetPlayerNumber = targetNumber;
	specialDesignation = [special copy];
	
	return self;
}

- (void)dealloc
{
	[specialDesignation release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	// Override to add message payload to outgoing messages
	return [NSString stringWithFormat:@"%@ %ld %@ %ld", iTetSpecialMessageTag, (long)[self targetPlayerNumber], [self specialDesignation], (long)[self senderPlayerNumber]];
}

#pragma mark -
#pragma mark Accessors

@synthesize senderPlayerNumber;
@synthesize targetPlayerNumber;
@synthesize specialDesignation;

@end
