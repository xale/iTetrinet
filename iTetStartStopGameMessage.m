//
//  iTetStartStopGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//

#import "iTetStartStopGameMessage.h"
#import "iTetPlayer.h"
#import "NSString+MessageData.h"

@implementation iTetStartStopGameMessage

+ (id)startMessageFromSender:(iTetPlayer*)sender
{
	return [[[self alloc] initWithSenderNumber:[sender playerNumber]
									 startGame:YES] autorelease];
}

+ (id)stopMessageFromSender:(iTetPlayer*)sender
{
	return [[[self alloc] initWithSenderNumber:[sender playerNumber]
									 startGame:NO] autorelease];
}

- (id)initWithSenderNumber:(NSInteger)playerNumber
				 startGame:(BOOL)start
{
	messageType = startStopGameMessage;
	
	startGame = start;
	senderNumber = playerNumber;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetStartStopGameMessageFormat =	@"startgame %d %d";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetStartStopGameMessageFormat, ([self startGame]?1:0), [self senderNumber]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

@synthesize startGame;
@synthesize senderNumber;

@end
