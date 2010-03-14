//
//  iTetPlayerLostMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
//

#import "iTetPlayerLostMessage.h"
#import "iTetPlayer.h"
#import "NSString+ASCIIData.h"

@implementation iTetPlayerLostMessage

+ (id)messageForPlayer:(iTetPlayer*)player
{
	return [[[self alloc] initWithPlayerNumber:[player playerNumber]] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)playerNum
{
	messageType = playerLostMessage;
	
	playerNumber = playerNum;
	
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
	messageType = playerLostMessage;
	
	// Convert the message to a string, and parse as the player number
	playerNumber = [[NSString stringWithASCIIData:messageData] integerValue];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlayerLostMessageFormat =	@"playerlost %d";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetPlayerLostMessageFormat, [self playerNumber]];
	
	return [rawMessage dataUsingEncoding:NSASCIIStringEncoding
					allowLossyConversion:YES];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;

@end
