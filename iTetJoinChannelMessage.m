//
//  iTetJoinChannelMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/11/10.
//

#import "iTetJoinChannelMessage.h"
#import "iTetPlayer.h"
#import "NSString+MessageData.h"

@implementation iTetJoinChannelMessage

+ (id)messageWithChannelName:(NSString*)nameOfChannel
					  player:(iTetPlayer*)player
{
	return [[[self alloc] initWithChannelName:nameOfChannel
									   player:player] autorelease];
}
			
- (id)initWithChannelName:(NSString*)nameOfChannel
				   player:(iTetPlayer*)player
{
	messageType = plineChatMessage;
	
	// Ensure that the channel name begins with a '#'
	if ([nameOfChannel rangeOfString:@"#" options:NSAnchoredSearch].location == NSNotFound)
		channelName = [[NSString alloc] initWithFormat:@"#%@", nameOfChannel];
	else
		channelName = [nameOfChannel copy];
	
	playerNumber = [player playerNumber];
	
	return self;
}

- (void)dealloc
{
	[channelName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetJoinChannelMessageFormat =	@"pline %d /join %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetJoinChannelMessageFormat, [self playerNumber], [self channelName]];
	
	return [rawMessage messageData];
}

#pragma mark -
#pragma mark Accessors

@synthesize channelName;
@synthesize playerNumber;

@end
