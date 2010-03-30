//
//  iTetFieldstringMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//

#import "iTetFieldstringMessage.h"
#import "iTetPlayer.h"
#import "iTetField.h"
#import "NSString+MessageData.h"

@implementation iTetFieldstringMessage

+ (id)fieldMessageForPlayer:(iTetPlayer*)player
{
	return [[[self alloc] initWithContents:[[player field] fieldstring]
							  playerNumber:[player playerNumber]
							 partialUpdate:NO] autorelease];
}

+ (id)partialUpdateMessageForPlayer:(iTetPlayer*)player
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
	
	// Convert the message to a string, and split into space-separated tokens
	NSArray* messageTokens = [[NSString stringWithMessageData:messageData] componentsSeparatedByString:@" "];
	
	// Parse the first token as the sender player's number
	playerNumber = [[messageTokens objectAtIndex:0] integerValue];
	
	// If present, treat the rest of the data as the fieldstring
	if (([messageTokens count] > 1) && ([[messageTokens objectAtIndex:1] length] > 0))
	{
		fieldstring = [[messageTokens objectAtIndex:1] retain];
		
		// Determine if this is a partial update, based on the first character of the fieldstring
		unichar first = [fieldstring characterAtIndex:0];
		partial = ((first >= 0x21) && (first <= 0x2F));
	}
	else
	{
		// Blank update: I have no idea what this is supposed to indicate, but some clients will send them
		fieldstring = [[NSString alloc] init];
		partial = YES;
	}
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetFieldstringMessageFormat =	@"f %d %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetFieldstringMessageFormat, [self playerNumber], [self fieldstring]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

@synthesize fieldstring;
@synthesize playerNumber;
@synthesize partial;

@end
