//
//  iTetSpecialMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//

#import "iTetSpecialMessage.h"
#import "iTetPlayer.h"

@implementation iTetSpecialMessage

+ (id)messageWithSpecialType:(iTetSpecialType)special
					  sender:(iTetPlayer*)sender
					  target:(iTetPlayer*)target
{
	return [[[self alloc] initWithSpecialType:special
								 senderNumber:[sender playerNumber]
								 targetNumber:[target playerNumber]] autorelease];
}

- (id)initWithSpecialType:(iTetSpecialType)special
			 senderNumber:(NSInteger)senderNum
			 targetNumber:(NSInteger)targetNum
{
	messageType = specialMessage;
	
	specialType = special;
	senderNumber = senderNum;
	targetNumber = targetNum;
	
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
	messageType = specialMessage;
	
	// FIXME: WRITEME
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetSpecialMessageFormat =	@"sb %d %@ %d";

- (NSData*)rawMessageData
{
	// FIXME: WRITEME
	return nil;
}

#pragma mark -
#pragma mark Accessors

@synthesize specialType;
@synthesize senderNumber;
@synthesize targetNumber;

@end
