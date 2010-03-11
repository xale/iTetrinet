//
//  iTetPlineChatMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetPlineChatMessage.h"
#import "iTetPlayer.h"
#import "NSString+ASCIIData.h"
#import "NSData+Searching.h"
#import "iTetTextAttributes.h"

@implementation iTetPlineChatMessage

+ (id)messageWithContents:(NSAttributedString*)contentsOfMessage
			   fromPlayer:(iTetPlayer*)player
{
	return [[[self alloc] initWithContents:contentsOfMessage
						  fromPlayerNumber:[player playerNumber]] autorelease];
}

- (id)initWithContents:(NSAttributedString*)contentsOfMessage
	  fromPlayerNumber:(NSInteger)playerNumber
{
	messageType = plineChatMessage;
	
	senderNumber = playerNumber;
	messageContents = [contentsOfMessage copy];
	
	return self;
}

- (void)dealloc
{
	[messageContents release];
	
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
	messageType = plineChatMessage;
	
	// Find the first space in the message data
	NSUInteger firstSpace = [messageData indexOfByte:(uint8_t)' '];
	
	if (firstSpace != NSNotFound)
	{
		// Split the data at the space, convert the first token to a string, and parse it as the sender player's number
		senderNumber = [[NSString stringWithASCIIData:[messageData subdataToIndex:firstSpace]] integerValue];
		
		// Convert the remaining data to the message contents as an attributed string
		messageContents = [[iTetTextAttributes formattedMessageFromData:[messageData subdataFromIndex:(firstSpace + 1)]] retain];
	}
	else
	{
		// Treat the message data as the sender's player number, and the message contents as blank
		senderNumber = [[NSString stringWithASCIIData:messageData] integerValue];
		messageContents = [[NSString alloc] init];
	}
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlineChatMessageFormat =	@"pline %d ";

- (NSData*)rawMessageData
{
	// Create the message format
	NSString* initialFormat = [NSString stringWithFormat:iTetPlineChatMessageFormat, [self senderNumber]];
	
	// Append the message contents, convert to NSData, and return
	return [self rawMessageDataByAppendingContentsToString:initialFormat];
}

#pragma mark -
#pragma mark Utility

- (NSData*)rawMessageDataByAppendingContentsToString:(NSString*)initialFormat
{
	// Create a mutable attributed string with the existing format at the base
	NSMutableAttributedString* fullMessage = [[[NSMutableAttributedString alloc] initWithString:initialFormat] autorelease];
	
	// Append the attributed message contents
	[fullMessage appendAttributedString:messageContents];
	
	// Make note of the range of the output string with attributes
	NSRange attributedRange;
	attributedRange.location = ([fullMessage length] - [initialFormat length]);
	attributedRange.length = ([fullMessage length] - attributedRange.location);
	
	// Convert the completed message to data
	return [iTetTextAttributes dataFromFormattedMessage:fullMessage
									withAttributedRange:attributedRange];
}

#pragma mark -
#pragma mark Accessors

@synthesize senderNumber;
@synthesize messageContents;

@end
