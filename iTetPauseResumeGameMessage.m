//
//  iTetPauseResumeGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
//

#import "iTetPauseResumeGameMessage.h"
#import "NSString+ASCIIData.h"

@implementation iTetPauseResumeGameMessage

+ (id)pauseGameMessageWithSenderNumber:(NSInteger)playerNumber
{
	return [[[self alloc] initWithSenderNumber:playerNumber
									 pauseGame:YES] autorelease];
}

+ (id)resumeGameMessageWithSenderNumber:(NSInteger)playerNumber
{
	return [[[self alloc] initWithSenderNumber:playerNumber
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
	NSArray* tokens = [[NSString stringWithASCIIData:messageData] componentsSeparatedByString:@" "];
	
	// Treat the first token as the "pause state"
	pauseGame = [[tokens objectAtIndex:0] boolValue];
	
	// Parse the second token as the sender's player number
	senderNumber = [[tokens objectAtIndex:1] integerValue];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPauseResumeGameMessageFormat =	@"pause %d %d";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetPauseResumeGameMessageFormat, ([self pauseGame]?1:0), [self senderNumber]];
	
	return [rawMessage dataUsingEncoding:NSASCIIStringEncoding
					allowLossyConversion:YES];
}

#pragma mark -
#pragma mark Accessors

@synthesize pauseGame;
@synthesize senderNumber;

@end
