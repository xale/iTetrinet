//
//  iTetPlineMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetPlineMessage.h"
#import "NSString+ASCIIData.h"
#import "NSData+Searching.h"
#import "iTetTextAttributes.h"

@implementation iTetPlineMessage

+ (id)messageWithContents:(NSAttributedString*)contentsOfMessage
		 fromPlayerNumber:(NSInteger)playerNumber
			actionMessage:(BOOL)isAction
{
	return [[[self alloc] initWithContents:contentsOfMessage
						  fromPlayerNumber:playerNumber
							 actionMessage:isAction] autorelease];
}

- (id)initWithContents:(NSAttributedString*)contentsOfMessage
	  fromPlayerNumber:(NSInteger)playerNumber
		 actionMessage:(BOOL)isAction
{
	messageType = plineMessage;
	
	senderNumber = playerNumber;
	messageContents = [contentsOfMessage copy];
	action = isAction;
	
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
	messageType = plineMessage;
	
	// Find the first space in the message data
	NSUInteger firstSpace = [messageData indexOfByte:(uint8_t)' '];
	
	// Split the data at the space, convert the first token to a string, and parse it as the sender player's number
	senderNumber = [[NSString stringWithASCIIData:[messageData subdataToIndex:firstSpace]] integerValue];
	
	// Convert the remaining data to the message contents as an attributed string
	messageContents = [[iTetTextAttributes formattedMessageFromData:[messageData subdataFromIndex:(firstSpace + 1)]] retain];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlineChatMessageFormat =	@"pline %d ";
NSString* const iTetPlineActionMessageFormat =	@"plineact %d ";

- (NSData*)rawMessageData
{
	// Create the message format
	NSString* initialFormat;
	if ([self isAction])
		initialFormat = [NSString stringWithFormat:iTetPlineActionMessageFormat, [self senderNumber]];
	else
		initialFormat = [NSString stringWithFormat:iTetPlineChatMessageFormat, [self senderNumber]];
	
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
@synthesize action;

@end
