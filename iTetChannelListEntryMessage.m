//
//  iTetChannelListEntryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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
	
	// Wrap the third token (the channel description) in HTML "paragraph" tags, to make it a valid XML element
	channelDescription = [NSString stringWithFormat:@"<p>%@</p>", [quotedTokens objectAtIndex:3]];
	
	// Attempt to parse the description as HTML
	NSError* parseError = nil;
	NSXMLElement* html = [[NSXMLElement alloc] initWithXMLString:channelDescription
														   error:&parseError];
	if (parseError != nil)
	{
		NSLog(@"WARNING: error parsing HTML formatting on description of channel '%@': %@", channelName, [parseError description]);
		channelDescription = [[quotedTokens objectAtIndex:3] retain];
	}
	else
	{
		// Convert to a raw string, stripping HTML formatting
		channelDescription = [[html stringValue] retain];
		[html release];
	}
	
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
