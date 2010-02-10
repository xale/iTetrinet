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

NSString* const iTetPlineFormat =		@"pline %d ";
NSString* const iTetPlineActionFormat =	@"plineact %s ";

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
	NSMutableAttributedString* toSend = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format, [localPlayer playerNumber]]] autorelease];
	[toSend appendAttributedString:message];
	NSRange attrRange;
	attrRange.location = ([toSend length] - [message length]);
	attrRange.length = ([toSend length] - attrRange.location);
	[[appController networkController] sendAttributedMessage:toSend
							     attributedRange:attrRange];
	
	// If the message is not a slash command, (other than /me) add the line to the chat view
	if (action || ([[message string] characterAtIndex:0] != '/'))
	{
		[self appendChatLine:message
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

- (void)appendChatLine:(NSAttributedString*)line
{
	// Add the line
	[[chatView textStorage] appendAttributedString:line];
	
	// Add a line terminator
	[[[chatView textStorage] mutableString] appendFormat:@"%C", NSParagraphSeparatorCharacter];
	
	// Scroll the chat view to see the new line
	[chatView scrollRangeToVisible:NSMakeRange([[chatView textStorage] length], 0)];
}

- (void)appendChatLine:(NSAttributedString*)line
	  fromPlayerName:(NSString*)playerName
		    action:(BOOL)isAction
{
	NSMutableAttributedString* formattedMessage = [[[NSMutableAttributedString alloc] init] autorelease];
	NSDictionary* boldAttribute = [NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Helvetica-Bold" size:12.0]
										    forKey:NSFontAttributeName];
	if (isAction)
	{
		// Append an asterisk in bold (to indicate an action)
		NSAttributedString* asterisk = [[[NSAttributedString alloc] initWithString:@"*"
												    attributes:boldAttribute] autorelease];
		[formattedMessage appendAttributedString:asterisk];
		
		// Append the player's name
		[[formattedMessage mutableString] appendFormat:@" %@ ", playerName];
	}
	else
	{
		// Append the player's name and a colon, in bold
		NSAttributedString* name = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", playerName]
												attributes:boldAttribute] autorelease];
		[formattedMessage appendAttributedString:name];
	}
	
	// Append the message contents
	[formattedMessage appendAttributedString:line];
	
	// Add the message to the chat view
	[self appendChatLine:formattedMessage];
}

- (void)appendStatusMessage:(NSString*)message
{
	// Create a centered paragraph style
	NSMutableParagraphStyle* statusMessageStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[statusMessageStyle setAlignment:NSCenterTextAlignment];
	
	// Create a bold font
	NSFont* font = [NSFont fontWithName:@"Helvetica-Bold" size:12.0];
	
	// Create an attributed string with the message and the above attributes
	NSDictionary* attrDict = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, statusMessageStyle, NSParagraphStyleAttributeName, nil];
	NSAttributedString* formattedMessage = [[[NSAttributedString alloc] initWithString:message
													attributes:attrDict] autorelease];
	
	// Append the message to the chat view
	[self appendChatLine:formattedMessage];
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
