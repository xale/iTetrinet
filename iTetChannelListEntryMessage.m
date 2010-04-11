//
//  iTetChannelListEntryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//

#import "iTetChannelListEntryMessage.h"
#import "NSString+MessageData.h"
#import "NSData+SingleByte.h"
#import "NSData+Subdata.h"
#import "iTetTextAttributes.h"

@implementation iTetChannelListEntryMessage

- (void)dealloc
{
	[channelName release];
	[channelDescription release];
	
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
	messageType = channelListEntryMessage;
	
	 // Convert the data to a string, and split on quotation marks
	 NSArray* quotedTokens = [[NSString stringWithMessageData:messageData] componentsSeparatedByString:@"\""];
	
	// Check that the message contains the correct number of quoted tokens
	if ([quotedTokens count] != 5)
		goto abort;
	
	// Treat the first quoted token as the channel name (ignoring the blank string before the first quotatation mark)
	channelName = [[quotedTokens objectAtIndex:1] retain];
	
	// Treat the second token as the channel description (ignoring the space between the second and third quotation marks)
	NSString* description = [quotedTokens objectAtIndex:3];
	
	// Add the default font information to the description
	// FIXME: hacky
	NSFont* listFont = [iTetTextAttributes channelsListTextFont];
	description = [NSString stringWithFormat:@"<p style=\"font-family:%@; font-size:%fpx\">%@</p>", [listFont fontName], [listFont pointSize], description];
	
	// Parse the HTML formatting on the description (NOTE: this uses WebKit's HTML engine, and causes this method—and the call stack below it—to fork into another thread of execution; see iTetChannelsViewController's -onSocket:didReadData:withTag: for further discussion)
	NSDictionary* parseOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:iTetDefaultStringEncoding]
															 forKey:NSCharacterEncodingDocumentOption];
	channelDescription = [[NSAttributedString alloc] initWithHTML:[description dataUsingEncoding:iTetDefaultStringEncoding]
														  options:parseOptions
											   documentAttributes:NULL];
	
	// Split the remaining tokens on spaces
	NSArray* unquotedTokens = [[quotedTokens objectAtIndex:4] componentsSeparatedByString:@" "];
	
	// Check that the message contains the correct number of tokens
	if ([unquotedTokens count] != 5)
		goto abort;
	
	// Parse the remaining tokens (skipping the blank first token) as the channel's player count, player capacity, priority, and game state
	playerCount = [[unquotedTokens objectAtIndex:1] integerValue];
	maxPlayers = [[unquotedTokens objectAtIndex:2] integerValue];
	priority = [[unquotedTokens objectAtIndex:3] integerValue];
	switch ([[unquotedTokens objectAtIndex:4] integerValue])
	{
		case 1:
			gameState = gameNotPlaying;
			break;
		case 2:
			gameState = gamePlaying;
			break;
		case 3:
			gameState = gamePaused;
			break;
		default:
			NSLog(@"WARNING: invalid game state in channel list entry");
			break;
	}
	
	return self;
	
abort:
	[self release];
	return nil;
}

#pragma mark -
#pragma mark Accessors

@synthesize channelName;
@synthesize channelDescription;
@synthesize playerCount;
@synthesize maxPlayers;
@synthesize priority;
@synthesize gameState;

@end
