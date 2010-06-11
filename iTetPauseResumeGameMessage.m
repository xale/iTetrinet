//
//  iTetPauseResumeGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPauseResumeGameMessage.h"
#import "iTetPlayer.h"
#import "NSString+MessageData.h"

@implementation iTetPauseResumeGameMessage

+ (id)pauseMessageFromSender:(iTetPlayer*)sender
{
	return [[[self alloc] initWithSenderNumber:[sender playerNumber]
									 pauseGame:YES] autorelease];
}

+ (id)resumeMessageFromSender:(iTetPlayer*)sender
{
	return [[[self alloc] initWithSenderNumber:[sender playerNumber]
									 pauseGame:NO] autorelease];
}

- (id)initWithSenderNumber:(NSInteger)playerNumber
				 pauseGame:(BOOL)pause
{
	messageType = pauseResumeGameMessage;
	
	pauseGame = pause;
	senderNumber = playerNumber;
	
	return self;
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = pauseResumeGameMessage;
	
	// Convert the message to a string, and split into space-delimited tokens
	NSArray* tokens = [[NSString stringWithMessageData:messageData] componentsSeparatedByString:@" "];
	
	// Treat the first token as the "pause state"
	pauseGame = [[tokens objectAtIndex:0] boolValue];
	
	// If present, parse the second token as the sender's player number
	if ([tokens count] > 1)
		senderNumber = [[tokens objectAtIndex:1] integerValue];
	else
		senderNumber = 0;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPauseResumeGameMessageFormat =	@"pause %d %d";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetPauseResumeGameMessageFormat, ([self pauseGame]?1:0), [self senderNumber]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

@synthesize pauseGame;
@synthesize senderNumber;

@end
