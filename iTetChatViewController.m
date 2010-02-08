//
//  iTetChatViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/16/09.
//

#import "iTetChatViewController.h"
#import "iTetAppController.h"
#import "iTetNetworkController.h"
#import "iTetChannelInfo.h"
#import "iTetPlayer.h"

@implementation iTetChatViewController

- (id)init
{	
	channels = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
	[channels release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	// Clear the chat text
	[self clearChat];
}

#pragma mark -
#pragma mark Interface Actions

NSString* const iTetPlineFormat =		@"pline %d %@";
NSString* const iTetPlineActionFormat =	@"plineact %s %@";

- (IBAction)sendMessage:(id)sender
{
	// Check if there is a message to send
	NSAttributedString* message = [messageField attributedStringValue];
	if ([message length] == 0)
		return;
	
	// Reformat the string using the 
	
	NSString* format;
	iTetPlayer* localPlayer = (iTetPlayer*)[appController localPlayer];
	
	BOOL action = ([message length] > 3) && [[[message string] substringToIndex:3] isEqualToString:@"/me"];
	
	// Format the message as text or action
	if (action)
	{
		format = iTetPlineActionFormat;
		message = [message attributedSubstringFromRange:NSMakeRange(4, [message length] - 4)];
	}
	else
	{
		format = iTetPlineFormat;
	}
	
	// Send the message
	// FIXME: apply formatting
	[[appController networkController] sendMessage:[NSString stringWithFormat:format, [localPlayer playerNumber], [message string]]];
	
	// If the message is not a slash command, (other than /me) add the line to the chat view
	if (action || ([[message string] characterAtIndex:0] != '/'))
	{
		// FIXME: formatting
		[self appendChatLine:[message string]
			fromPlayerName:[localPlayer nickname]
				  action:action];
	}
	
	// Clear the text field
	[messageField setStringValue:@""];
}

#pragma mark -
#pragma mark Chat Text

- (void)clearChat
{
	[chatView replaceCharactersInRange:NSMakeRange(0, [[chatView textStorage] length])
					withString:@""];
}

- (void)appendChatLine:(NSString*)line
{
	[chatView replaceCharactersInRange:NSMakeRange([[chatView textStorage] length], 0)
					withString:[NSString stringWithFormat:@"%@%C",
							line, NSLineSeparatorCharacter]];
	[chatView scrollRangeToVisible:NSMakeRange([[chatView textStorage] length], 0)];
}

- (void)appendChatLine:(NSString*)line
	  fromPlayerName:(NSString*)playerName
		    action:(BOOL)isAction
{
	// Determine which format to use
	NSString* format;
	if (isAction)
		format = @"* %@ %@";
	else
		format = @"%@: %@";
	
	// Append the formatted line to the chat text
	[self appendChatLine:[NSString stringWithFormat:format, playerName, line]];
	
	// FIXME: string attributes
}

#pragma mark -
#pragma mark Channels

/*- (void)requestChannelList
{
	// If there is already a pending channel request, ignore this one
	if (pendingChannelRequest)
		return;
	
	// Create a channel request message
	NSString* request = [NSString stringWithFormat:@"pline %d /list",
				   [iTetPlayersController localPlayerNumber]];
	
	// Send the request
	[iTetNetworkController sendMessage:request];
	pendingChannelRequest = YES;
}*/

- (void)addChannel:(NSString*)channelData
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Accessors

@synthesize channels;

@end
