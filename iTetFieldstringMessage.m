//
//  iTetFieldstringMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//

#import "iTetFieldstringMessage.h"
#import "iTetPlayer.h"
#import "iTetField.h"
#import "NSData+Searching.h"
#import "NSString+ASCIIData.h"

@implementation iTetFieldstringMessage

+ (id)messageWithFieldForPlayer:(iTetPlayer*)player
{
	return [[[self alloc] initWithContents:[[player field] fieldstring]
							  playerNumber:[player playerNumber]
							 partialUpdate:NO] autorelease];
}

+ (id)messageWithPartialUpdateForPlayer:(iTetPlayer*)player
{
	return [[[self alloc] initWithContents:[[player field] lastPartialUpdate]
							  playerNumber:[player playerNumber]
							 partialUpdate:YES] autorelease];
}

- (id)initWithContents:(NSString*)fieldstringContents
		  playerNumber:(NSInteger)playerNum
		 partialUpdate:(BOOL)isPartial
{
	messageType = fieldstringMessage;
	
	fieldstring = [fieldstringContents copy];
	playerNumber = playerNum;
	partial = isPartial;
	
	return self;
}

- (void)dealloc
{
	[fieldstring release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = fieldstringMessage;
	
	// Find the first space in the message data (there should be only one)
	NSUInteger firstSpace = [messageData indexOfByte:(uint8_t)' '];
	
	// Split the data at the space, convert the first token to a string, and parse it as the sender player's number
	playerNumber = [[NSString stringWithASCIIData:[messageData subdataToIndex:firstSpace]] integerValue];
	
	// Convert the remaining data into the fieldstring
	fieldstring = [[NSString stringWithASCIIData:[messageData subdataFromIndex:firstSpace]] retain];
	
	// Determine if this is a partial update, based on the first character of the fieldstring
	unichar first = [fieldstring characterAtIndex:0];
	partial = ((first >= 0x21) && (first <= 0x2F));
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetFieldstringMessageFormat =	@"f %d %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetFieldstringMessageFormat, [self playerNumber], [self fieldstring]];
	
	return [rawMessage dataUsingEncoding:NSASCIIStringEncoding
					allowLossyConversion:YES];
}

#pragma mark -
#pragma mark Accessors

@synthesize fieldstring;
@synthesize playerNumber;
@synthesize partial;

@end
