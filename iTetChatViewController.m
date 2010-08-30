//
//  iTetChatViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/16/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetChatViewController.h"

#import "iTetPlayersController.h"
#import "iTetLocalPlayer.h"

#import "iTetChannelInfo.h"

#import "iTetNetworkController.h"
#import "iTetMessage.h"

#import "NSAttributedString+TetrinetTextAttributes.h"
#import "iTetTextAttributes.h"

#import "iTetNotifications.h"
#import "iTetUserDefaults.h"

#import "NSAttributedString+Convenience.h"
#import "NSDictionary+AdditionalTypes.h"

@implementation iTetChatViewController

+ (void)initialize
{
	// Register default highlight color for local player's name
	NSData* colorData = [NSKeyedArchiver archivedDataWithRootObject:[[NSColor purpleColor] blendedColorWithFraction:0.5 ofColor:[NSColor blackColor]]];
	NSDictionary* defaults = [NSDictionary dictionaryWithObject:colorData
														 forKey:iTetLocalPlayerNameColorPrefKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];	
}

- (id)init
{
	// Register for player-event notifications
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	
	// Player joined
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerJoinedEventNotificationName
			 object:nil];
	
	// Player left
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerLeftEventNotificationName
			 object:nil];
	
	// Player kicked
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerKickedEventNotificationName
			 object:nil];
	
	// Player changed team
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerTeamChangeEventNotificationName
			 object:nil];
	
	return self;
}

- (void)awakeFromNib
{
	// Clear the chat text
	[self clearChat];
}

- (void)dealloc
{
	// De-register for player-event notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)submitChatMessage:(id)sender
{
	// Check if there is a message to send
	NSAttributedString* messageContents = [messageField attributedStringValue];
	if ([messageContents length] == 0)
		return;
	
	// Check if the string is an emote
	BOOL action = [[messageContents string] hasPrefix:iTetActionMessagePrefix];
	
	// Construct the message
	iTetMessage* message;
	iTetPlayer* localPlayer = [playersController localPlayer];
	if (action)
	{
		// Trim off the emote prefix
		messageContents = [messageContents attributedSubstringFromRange:NSMakeRange([iTetActionMessagePrefix length], [messageContents length] - [iTetActionMessagePrefix length])];
		
		// Create the message
		message = [iTetMessage messageWithMessageType:plineActionMessage];
	}
	else
	{
		// Create the message
		message = [iTetMessage messageWithMessageType:plineChatMessage];
	}
	
	// Fill the message contents
	[[message contents] setInteger:[localPlayer playerNumber]
							forKey:iTetMessagePlayerNumberKey];
	[[message contents] setObject:messageContents
						   forKey:iTetMessageChatContentsKey];
	
	// Send the message
	[networkController sendMessage:message];
	
	// If the message is not a slash command, (other than /me) add the line to the chat view
	if (action || ![[messageContents string] hasPrefix:iTetCommandMessagePrefix])
	{
		[self appendChatLine:messageContents
				  fromPlayer:localPlayer
					  action:action];
	}
	
	// Clear the text field
	[messageField setStringValue:@""];
}

- (IBAction)changeTextColor:(id)sender
{
	NSTextView* editor = (NSTextView*)[messageField currentEditor];
	
	// Determine the text color to use
	NSColor* textColor = [iTetTextAttributes chatTextColorForCode:[sender tag]];
	
	// Determine if there is text selected
	NSRange selection = [editor selectedRange];
	if (selection.length > 0)
	{
		// Change the text color of the selection
		[editor setTextColor:textColor
					   range:selection];
	}
	else
	{
		// Set the color of the text being typed
		// Get the current typing attributes
		NSMutableDictionary* attrDict = [[editor typingAttributes] mutableCopy];
		
		// Change the text color
		[attrDict setObject:textColor
					 forKey:NSForegroundColorAttributeName];
		[editor setTypingAttributes:attrDict];
		
		[attrDict release];
	}
}

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Color change actions are available if the message field has keyboard focus
	if ([item action] == @selector(changeTextColor:))
		return ([messageField currentEditor] != nil);
	
	return YES;
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
			fromPlayer:(iTetPlayer*)player
				action:(BOOL)isAction
{
	NSMutableAttributedString* formattedMessage;
	if (isAction)
	{
		// Begin the message line with a dot (to indicate an action)
		formattedMessage = [NSMutableAttributedString attributedStringWithString:iTetLocalActionMessageIndicator];
		
		// Append the player's name (and a space)
		[[formattedMessage mutableString] appendFormat:@"%@ ", [player nickname]];
	}
	else
	{
		// Begin the mesasge line with the player's name, followed by a colon and a space
		formattedMessage = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@: ", [player nickname]]];
	}
	
	// Format the name in bold
	NSRange nameRange = NSMakeRange(0, ([[player nickname] length] + 1));
	[formattedMessage applyFontTraits:NSBoldFontMask
								range:nameRange];
	
	// If the player is the local player, change the color of the name
	if ([player isLocalPlayer])
	{
		[formattedMessage addAttributes:[iTetTextAttributes localPlayerNameTextColorAttributes]
								  range:nameRange];
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
	NSDictionary* attrDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  font, NSFontAttributeName,
							  statusMessageStyle, NSParagraphStyleAttributeName,
							  nil];
	NSAttributedString* formattedMessage = [[[NSAttributedString alloc] initWithString:message
																			attributes:attrDict] autorelease];
	
	// Append the message to the chat view
	[self appendChatLine:formattedMessage];
}

#pragma mark -
#pragma mark Player Event Notifications

#define iTetPlayerJoinedEventStatusMessageFormat		NSLocalizedStringFromTable(@"%@ has joined the channel", @"ChatViewController", @"Status message appended to the chat view when a player joins the channel")
#define iTetPlayerLeftEventStatusMessageFormat			NSLocalizedStringFromTable(@"%@ has left the channel", @"ChatViewController", @"Status message appended to the chat view when a player leaves the channel")
#define iTetPlayerJoinedTeamEventStatusMessageFormat	NSLocalizedStringFromTable(@"%@ has joined team '%@'", @"ChatViewController", @"Status message appended to the chat view when a player joins a new team")
#define iTetPlayerSwitchedTeamEventStatusMessageFormat	NSLocalizedStringFromTable(@"%@ has switched to team '%@'", @"ChatViewController", @"Status message appended to the chat view when a player changes from one team to another")
#define iTetPlayerLeftTeamEventStatusMessageFormat		NSLocalizedStringFromTable(@"%@ has left team '%@'", @"ChatViewController", @"Status message appended to the chat view when a player leaves the team he or she was playing for")
#define iTetLocalPlayerKickedStatusMessage				NSLocalizedStringFromTable(@"You have been kicked from the server", @"NetworkController", @"Status message appended to the chat view when the server informs the client that it is about to be disconnected")
#define iTetPlayerKickedStatusMessageFormat				NSLocalizedStringFromTable(@"%@ has been kicked from the server", @"NetworkController", @"Status message appended to the chat view when a player is kicked from the server")

- (void)playerEventNotification:(NSNotification*)notification
{
	// Determine the type of event, and append the appropriate status message to the chat view
	NSString* eventType = [notification name];
	iTetPlayer* player = [[notification userInfo] objectForKey:iTetNotificationPlayerKey];
	if ([eventType isEqualToString:iTetPlayerJoinedEventNotificationName])
	{
		// Player joined
		// Ignore notifications about the local player
		if ([player isLocalPlayer])
			return;
		
		[self appendStatusMessage:[NSString stringWithFormat:iTetPlayerJoinedEventStatusMessageFormat, [player nickname]]];
	}
	else if ([eventType isEqualToString:iTetPlayerLeftEventNotificationName])
	{
		// Player left
		// Ignore notifications about the local player
		if ([player isLocalPlayer])
			return;
		
		[self appendStatusMessage:[NSString stringWithFormat:iTetPlayerLeftEventStatusMessageFormat, [player nickname]]];
	}
	else if ([eventType isEqualToString:iTetPlayerKickedEventNotificationName])
	{
		// Player left
		// Determine if the local player is being kicked
		if ([player isLocalPlayer])
			[self appendStatusMessage:iTetLocalPlayerKickedStatusMessage];
		else
			[self appendStatusMessage:[NSString stringWithFormat:iTetPlayerKickedStatusMessageFormat, [player nickname]]];
	}
	else if ([eventType isEqualToString:iTetPlayerTeamChangeEventNotificationName])
	{
		// Player team-change
		// If this is a notification about the local player, (which shouldn't happen, but some servers might be strange) ignore it
		if ([player isLocalPlayer])
			return;
		
		// Get the new and old team names
		NSString* oldTeamName = [[notification userInfo] objectForKey:iTetNotificationOldTeamNameKey];
		NSString* newTeamName = [[notification userInfo] objectForKey:iTetNotificationNewTeamNameKey];
		
		// Check if the player is joining a team, switching teams, or leaving a team
		if ([oldTeamName length] > 0)
		{
			if ([newTeamName length] > 0)
				[self appendStatusMessage:[NSString stringWithFormat:iTetPlayerSwitchedTeamEventStatusMessageFormat, [player nickname], newTeamName]];
			else
				[self appendStatusMessage:[NSString stringWithFormat:iTetPlayerLeftTeamEventStatusMessageFormat, [player nickname], oldTeamName]];
		}
		else
		{
			if ([newTeamName length] > 0)
				[self appendStatusMessage:[NSString stringWithFormat:iTetPlayerJoinedTeamEventStatusMessageFormat, [player nickname], newTeamName]];
		}
	}
}

@end
