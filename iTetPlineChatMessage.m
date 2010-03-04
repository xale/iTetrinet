//
//  iTetPlineChatMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetPlineChatMessage.h"
#import "NSString+ASCIIData.h"
#import "NSData+Searching.h"
#import "iTetTextAttributes.h"

@implementation iTetPlineChatMessage

+ (id)plineChatMessageWithContents:(NSAttributedString*)contentsOfMessage
				  fromPlayerNumber:(NSInteger)playerNumber
{
	return [[[self alloc] initWithContents:contentsOfMessage
						  fromPlayerNumber:playerNumber] autorelease];
}

- (id)initWithContents:(NSAttributedString*)contentsOfMessage
	  fromPlayerNumber:(NSInteger)playerNumber
{
	messageType = playerTeamMessage;
	
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
#pragma mark iTetIncomingMessage Protocol Initializer

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = playerTeamMessage;
	
	// Find the space in the message data
	NSUInteger firstSpace = [messageData indexOfByte:(uint8_t)' '];
	
	// Check that a space was found
	if (firstSpace == NSNotFound)
	{
		NSLog(@"WARNING: attempt to create pline chat message from invalid data");
		return nil;
	}
	
	// Split the data at the space, convert the first token to a string, and parse it as the sender player's number
	senderNumber = [[NSString stringWithASCIIData:[messageData subdataToIndex:firstSpace]] integerValue];
	
	// Convert the remaining data to the message contents as an attributed string
	messageContents = [[iTetTextAttributes formattedMessageFromData:[messageData subdataFromIndex:(firstSpace + 1)]] retain];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlineChatMessageFormat =	@"pline %d ";

- (NSData*)rawMessageData
{
	// Create the message format
	NSString* initialFormat = [NSString stringWithFormat:iTetPlineChatMessageFormat, [self senderNumber]];
	
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
