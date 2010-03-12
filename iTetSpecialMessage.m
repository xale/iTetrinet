//
//  iTetSpecialMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//

#import "iTetSpecialMessage.h"
#import "iTetPlayer.h"
#import "iTetSpecials.h"
#import "NSString+ASCIIData.h"

@implementation iTetSpecialMessage

+ (id)messageWithSpecialType:(iTetSpecialType)special
					  sender:(iTetPlayer*)sender
					  target:(iTetPlayer*)target
{
	return [[[self alloc] initWithSpecialType:special
								 senderNumber:[sender playerNumber]
								 targetNumber:[target playerNumber]] autorelease];
}

+ (id)messageWithClassicStyleLines:(NSInteger)lines
							sender:(iTetPlayer*)sender
{
	return [[[self alloc] initWithSpecialType:[iTetSpecials specialTypeForClassicLines:lines]
								 senderNumber:[sender playerNumber]
								 targetNumber:0] autorelease];
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
	
	// Convert the message data to a string, and split on spaces
	NSArray* tokens = [[NSString stringWithASCIIData:messageData] componentsSeparatedByString:@" "];
	
	// Parse the first token as the target's player number
	targetNumber = [[tokens objectAtIndex:0] integerValue];
	
	// Convert the second token to a special type
	specialType = [iTetSpecials specialTypeFromMessageName:[tokens objectAtIndex:1]];
	
	// Parse the third token as the sender's player number
	senderNumber = [[tokens objectAtIndex:2] integerValue];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetSpecialMessageFormat =	@"sb %d %@ %d";

- (NSData*)rawMessageData
{
	// Get the message version of the special type
	NSString* specialName = [iTetSpecials messageNameForSpecialType:[self specialType]];
	
	NSString* rawMessage = [NSString stringWithFormat:iTetSpecialMessageFormat, [self targetNumber], specialName, [self senderNumber]];
	
	return [rawMessage dataUsingEncoding:NSASCIIStringEncoding
					allowLossyConversion:YES];
}

#pragma mark -
#pragma mark Accessors

@synthesize specialType;
@synthesize senderNumber;
@synthesize targetNumber;

@end
