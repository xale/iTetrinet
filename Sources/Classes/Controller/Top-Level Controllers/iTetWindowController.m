//
//  iTetWindowController.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetWindowController.h"

#import "iTetNetworkController.h"
#import "iTetPlayersController.h"
#import "iTetGameViewController.h"

#import "iTetLocalPlayer.h"

#import "iTetUserDefaults.h"
#import "iTetPreferencesWindowController.h"

#import "iTetCountryCodeFlagImageTransformer.h"
#import "iTetCurrentChannelImageTransformer.h"
#import "iTetGameStateImageTransformer.h"
#import "iTetGameVersionTransformer.h"
#import "iTetProtocolTransformer.h"
#import "iTetWinlistEntryTypeImageTransformer.h"

#import "iTetGrowlController.h"

#import "iTetCommonLocalizations.h"

@implementation iTetWindowController

+ (void)initialize
{
	// Register value transformers
	// Country code/flag images
	[NSValueTransformer setValueTransformer:[iTetCountryCodeFlagImageTransformer valueTransformer]
									forName:[iTetCountryCodeFlagImageTransformer valueTransformerName]];
	
	// Current channel icon
	[NSValueTransformer setValueTransformer:[iTetCurrentChannelImageTransformer valueTransformer]
									forName:[iTetCurrentChannelImageTransformer valueTransformerName]];
	
	// Game state icon
	[NSValueTransformer setValueTransformer:[iTetGameStateImageTransformer valueTransformer]
									forName:[iTetGameStateImageTransformer valueTransformerName]];
	
	// Game version enum to name
	[NSValueTransformer setValueTransformer:[iTetGameVersionTransformer valueTransformer]
									forName:[iTetGameVersionTransformer valueTransformerName]];
	
	// Protocol enum to name
	[NSValueTransformer setValueTransformer:[iTetProtocolTransformer valueTransformer]
									forName:[iTetProtocolTransformer valueTransformerName]];
	
	// Winlist entry type to image
	[NSValueTransformer setValueTransformer:[iTetWinlistEntryTypeImageTransformer valueTransformer]
									forName:[iTetWinlistEntryTypeImageTransformer valueTransformerName]];
}

- (void)awakeFromNib
{
	// Add a border to the bottom of the window (this can be done in IB, but only for 10.6+)
	[window setAutorecalculatesContentBorderThickness:NO
											  forEdge:NSMinYEdge];
	[window setContentBorderThickness:25
							  forEdge:NSMinYEdge];
	
	// Set up the Growl controller/delegate
	[GrowlApplicationBridge setGrowlDelegate:[iTetGrowlController sharedGrowlController]];
}

- (void)dealloc
{
	[prefsWindowController release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSApplication Delegate Methods

#define iTetQuitWithGameInProgressAlertInformativeText	NSLocalizedStringFromTable(@"A game is currently in progress. Are you sure you want to quit?", @"WindowController", @"Informative text on alert displayed when the user attempts to close the application while participating in a game")
#define iTetQuitWithGameInProgressConfirmButtonTitle	NSLocalizedStringFromTable(@"Quit Anyway", @"WindowController", @"Title of button on 'quit with game in progress?' alert that allows the user to close the application")

#define iTetQuitWithConnectionOpenAlertTitle			NSLocalizedStringFromTable(@"Open Connection", @"WindowController", @"Title of alert displayed when the user attempts to close the application while connected to a server (but not currently participating in a game)")
#define iTetQuitWithConnectionOpenAlertInformativeText	NSLocalizedStringFromTable(@"You are currently connected to the server '%@'. Are you sure you want to quit?", @"WindowController", @"Informative text on alert displayed when the user attempts to close the application while connected to a server (but not currently participating in a game)")
#define iTetQuitWithConnectionOpenConfirmButtonTitle	NSLocalizedStringFromTable(@"Disconnect and Quit", @"WindowController", @"Title of button on 'quit while connected to server?' alert that allows the user to close the open connection and quit the application")
#define iTetQuitWithConnectionOpenCancelButtonTitle		NSLocalizedStringFromTable(@"Don't Quit", @"WindowController", @"Title of button on 'quit while connected to server?' alert that allows the user to cancel closing and remain connected")

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{
	// Check if there is an open connection
	if ([networkController connectionOpen])
	{
		// Create an alert
		NSAlert* alert = [[[NSAlert alloc] init] autorelease];
		
		// Check if there is a game in progress
		if ([[playersController localPlayer] isPlaying])
		{
			[alert setMessageText:iTetGameInProgressAlertTitle];
			[alert setInformativeText:iTetQuitWithGameInProgressAlertInformativeText];
			[alert addButtonWithTitle:iTetQuitWithGameInProgressConfirmButtonTitle];
			[alert addButtonWithTitle:iTetContinuePlayingButtonTitle];
		}
		else
		{
			[alert setMessageText:iTetQuitWithConnectionOpenAlertTitle];
			[alert setInformativeText:[NSString stringWithFormat:iTetQuitWithConnectionOpenAlertInformativeText, [networkController currentServerAddress]]];
			[alert addButtonWithTitle:iTetQuitWithConnectionOpenConfirmButtonTitle];
			[alert addButtonWithTitle:iTetQuitWithConnectionOpenCancelButtonTitle];
		}
		
		// Run the alert as a modal sheet
		[alert beginSheetModalForWindow:window
						  modalDelegate:self
						 didEndSelector:@selector(connectionOpenAlertDidEnd:returnCode:contextInfo:)
							contextInfo:NULL];
		
		// Tell the application not to quit yet
		return NSTerminateCancel;
	}
	
	// Check if there is an offline game in progress
	if ([gameController gameInProgress])
	{
		// Make note if the game was paused, pause if not
		BOOL gameWasPaused = ([gameController gameplayState] == gamePaused);
		if (!gameWasPaused)
			[gameController pauseGame];
		
		// Create an alert
		NSAlert* alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:iTetGameInProgressAlertTitle];
		[alert setInformativeText:iTetQuitWithGameInProgressAlertInformativeText];
		[alert addButtonWithTitle:iTetQuitWithGameInProgressConfirmButtonTitle];
		[alert addButtonWithTitle:iTetContinuePlayingButtonTitle];
		
		// Run the alert as a modal sheet
		[alert beginSheetModalForWindow:window
						  modalDelegate:self
						 didEndSelector:@selector(offlineGameInProgressAlertDidEnd:returnCode:gameWasPaused:)
							contextInfo:[[NSNumber alloc] initWithBool:gameWasPaused]];
		
		// Tell the application not to quit yet
		return NSTerminateCancel;
	}
	
	// If the preferences window is open, check for unsaved state before terminating
	if ([[prefsWindowController window] isVisible])
	{
		return [prefsWindowController applicationShouldTerminate:sender];
	}
	
	// Otherwise, terminate immediately
	return NSTerminateNow;
}

- (void)connectionOpenAlertDidEnd:(NSAlert*)alert
					   returnCode:(NSInteger)returnCode
					  contextInfo:(void*)contextInfo
{
	// Ensure the sheet has closed
	[[alert window] orderOut:self];
	
	// If the user chose to cancel, abort quitting (do nothing)
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// If the user pressed "quit", disconnect, and try to quit again
	[networkController disconnect];
	[NSApp terminate:self];
}

- (void)offlineGameInProgressAlertDidEnd:(NSAlert*)alert
							  returnCode:(NSInteger)returnCode
						   gameWasPaused:(NSNumber*)pausedValue
{
	BOOL gameWasPaused = [pausedValue boolValue];
	[pausedValue release];
	
	// Ensure the sheet has closed
	[[alert window] orderOut:self];
	
	// If the user chose to cancel, abort quitting
	if (returnCode == NSAlertSecondButtonReturn)
	{
		// If the game in progress was not paused when this alert opened, resume it
		if (!gameWasPaused)
			[gameController resumeGame];
		
		return;
	}
	
	// If the user pressed "quit", end the offline game, and try to quit again
	[gameController endGame];
	[NSApp terminate:self];
}

#pragma mark -
#pragma mark NSWindow Delegate Methods

- (BOOL)windowShouldClose:(id)closingWindow
{
	[NSApp terminate:self];
	
	return NO;
}

#pragma mark -
#pragma mark NSTabView Delegate Methods

NSString* const iTetWindowControllerSelectedTabViewItemDidChangeNotification =	@"selectedTabViewItemDidChange";

- (void)tabView:(NSTabView*)view
didSelectTabViewItem:(NSTabViewItem*)item
{
	[[NSNotificationCenter defaultCenter] postNotificationName:iTetWindowControllerSelectedTabViewItemDidChangeNotification
														object:self];
}

#pragma mark -
#pragma mark Main Window Tabs

NSString* const iTetGameViewTabIdentifier =		@"game";

- (IBAction)switchToGameTab:(id)sender
{
	[tabView selectTabViewItemWithIdentifier:iTetGameViewTabIdentifier];
}

NSString* const iTetChatViewTabIdentifier =		@"chat";

- (IBAction)switchToChatTab:(id)sender
{
	[tabView selectTabViewItemWithIdentifier:iTetChatViewTabIdentifier];
}

NSString* const iTetWinlistViewTabIdentifier =	@"winlist";

- (IBAction)switchToWinlistTab:(id)sender
{
	[tabView selectTabViewItemWithIdentifier:iTetWinlistViewTabIdentifier];
}

#pragma mark -
#pragma mark Preferences Window

- (IBAction)showPreferences:(id)sender
{
	if (prefsWindowController == nil)
		prefsWindowController = [[iTetPreferencesWindowController alloc] init];
	
	[prefsWindowController showWindow:self];
	[[prefsWindowController window] makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark Accessors

@synthesize window;
@synthesize tabView;

@end
