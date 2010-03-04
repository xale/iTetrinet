//
//  iTetChatViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/16/09.
//

#import "iTetChatViewController.h"
#import "iTetAppController.h"
#import "iTetNetworkController.h"
#import "iTetTextAttributes.h"
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
NSString* const iTetPlineActionFormat =	@"plineact %d ";

- (IBAction)sendMessage:(id)sender
{
	// Check if there is a message to send
	NSAttributedString* message = [messageField attributedStringValue];
	if ([message length] == 0)
		return;
	
	// Check if the string is an action
	BOOL action = ([message length] > 3) && [[[message string] substringToIndex:3] isEqualToString:@"/me"];
	
	// Format the message as text or action
	NSString* format;
	if (action)
	{
		format = iTetPlineActionFormat;
		message = [message attributedSubstringFromRange:NSMakeRange(4, [message length] - 4)];
	}
	else
	{
		format = iTetPlineFormat;
	}
	
	// Concatenate the formatting with the message contents
	iTetPlayer* localPlayer = (iTetPlayer*)[appController localPlayer];
	NSMutableAttributedString* toSend = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format, [localPlayer playerNumber]]] autorelease];
	[toSend appendAttributedString:message];
	
	// Note the range of the concatenated string that has attributes
	NSRange attrRange;
	attrRange.location = ([toSend length] - [message length]);
	attrRange.length = ([toSend length] - attrRange.location);
	
	// Send the message
	[[appController networkController] sendMessageData:[iTetTextAttributes dataFromFormattedMessage:toSend
																				withAttributedRange:attrRange]];
	
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
	// If the chat view is not empty, add a line separator
	if ([[chatView textStorage] length] > 0)
		[[[chatView textStorage] mutableString] appendFormat:@"%C", NSParagraphSeparatorCharacter];
	
	// Add the line
	[[chatView textStorage] appendAttributedString:line];
	
	// Scroll the chat view to see the new line
	[chatView scrollRangeToVisible:NSMakeRange([[chatView textStorage] length], 0)];
}

- (void)appendChatLine:(NSAttributedString*)line
		fromPlayerName:(NSString*)playerName
				action:(BOOL)isAction
{
	NSMutableAttributedString* formattedMessage = [[[NSMutableAttributedString alloc] init] autorelease];
	
	// Create a bold version of the chat view's font
	NSFont* boldFont = [[NSFontManager sharedFontManager] convertFont:[chatView font]
														  toHaveTrait:NSBoldFontMask];
	NSDictionary* boldAttribute = [NSDictionary dictionaryWithObject:boldFont
															  forKey:NSFontAttributeName];
	if (isAction)
	{
		// Append a dot in bold (to indicate an action)
		NSAttributedString* asterisk = [[[NSAttributedString alloc] initWithString:@"•"
																		attributes:boldAttribute] autorelease];
		[formattedMessage appendAttributedString:asterisk];
		
		// Append the player's name in bold (and a space)
		[[formattedMessage mutableString] appendFormat:@"%@ ", playerName];
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
