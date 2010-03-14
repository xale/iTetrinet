//
//  iTetChatViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/16/09.
//

#import "iTetChatViewController.h"

#import "iTetAppController.h"

#import "iTetNetworkController.h"
#import "iTetPlineChatMessage.h"
#import "iTetPlineActionMessage.h"

#import "iTetChannelInfo.h"
#import "iTetLocalPlayer.h"

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

- (IBAction)submitChatMessage:(id)sender
{
	// Check if there is a message to send
	NSAttributedString* messageContents = [messageField attributedStringValue];
	if ([messageContents length] == 0)
		return;
	
	// Check if the string is an action
	BOOL action = ([messageContents length] > 3) && [[[messageContents string] substringToIndex:3] isEqualToString:@"/me"];
	
	// Construct the message
	iTetMessage<iTetOutgoingMessage>* message;
	iTetPlayer* localPlayer = [appController localPlayer];
	if (action)
	{
		// Trim off the "/me "
		messageContents = [messageContents attributedSubstringFromRange:NSMakeRange(4, [messageContents length] - 4)];
		
		// Create the message
		message = [iTetPlineActionMessage messageWithContents:messageContents
												   fromPlayer:localPlayer];
		
	}
	else
	{
		// Create the message
		message = [iTetPlineChatMessage messageWithContents:messageContents
												 fromPlayer:localPlayer];
	}
	
	// Send the message
	[[appController networkController] sendMessage:message];
	
	// If the message is not a slash command, (other than /me) add the line to the chat view
	if (action || ([[messageContents string] characterAtIndex:0] != '/'))
	{
		[self appendChatLine:messageContents
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
 }
 
 - (void)addChannel:(NSString*)channelData
 {
	// FIXME: WRITEME
 }*/

#pragma mark -
#pragma mark Accessors

@synthesize channels;

@end
