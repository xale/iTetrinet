//
//  iTetWindowController.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/10.
//

#import "iTetWindowController.h"
#import "iTetNetworkController.h"
#import "iTetPlayersController.h"

#import "iTetLocalPlayer.h"

#import "iTetPreferencesController.h"
#import "iTetPreferencesWindowController.h"

#import "iTetGameStateDescriptionTransformer.h"
#import "iTetProtocolTransformer.h"
#import "iTetSpecialNameTransformer.h"
#import "iTetWinlistEntryTypeImageTransformer.h"

@implementation iTetWindowController

+ (void)initialize
{
	// Register value transformers
	// Game state enum to description
	NSValueTransformer* transformer = [[[iTetGameStateDescriptionTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer
									forName:iTetGameStateDescriptionTransformerName];
	// Protocol enum to name
	transformer = [[[iTetProtocolTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer
									forName:iTetProtocolTransformerName];
	// Special code/number to name
	transformer = [[[iTetSpecialNameTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer
									forName:iTetSpecialNameTransformerName];
	// Winlist entry type to image
	transformer = [[[iTetWinlistEntryTypeImageTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer
									forName:iTetWinlistEntryTypeImageTransformerName];
	
	// Seed random number generator
	srandom(time(NULL));
}

- (void)awakeFromNib
{
	// Add a border to the bottom of the window (this can be done in IB, but only for 10.6+)
	[window setAutorecalculatesContentBorderThickness:NO
											  forEdge:NSMinYEdge];
	[window setContentBorderThickness:25
							  forEdge:NSMinYEdge];
}

- (void)dealloc
{
	[prefsWindowController release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSApplication Delegate Methods

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	// Check if there is an open connection
	if ([networkController connectionOpen])
	{
		// Create an alert
		NSAlert* alert = [[[NSAlert alloc] init] autorelease];
		
		// Check if there is a game in progress
		if ([[playersController localPlayer] isPlaying])
		{
			[alert setMessageText:@"Game in Progress"];
			[alert setInformativeText:@"A game is currently in progress. Are you sure you want to quit?"];
			[alert addButtonWithTitle:@"Quit Anyway"];
			[alert addButtonWithTitle:@"Continue Playing"];
		}
		else
		{
			[alert setMessageText:@"Open Connection"];
			[alert setInformativeText:[NSString stringWithFormat:@"You are currently connected to the server %@. Are you sure you want to quit?", [networkController currentServerAddress]]];
			[alert addButtonWithTitle:@"Disconnect and Quit"];
			[alert addButtonWithTitle:@"Don't Quit"];
		}
		
		// Run the alert as a modal sheet
		[alert beginSheetModalForWindow:window
						  modalDelegate:self
						 didEndSelector:@selector(connectionOpenAlertDidEnd:returnCode:contextInfo:)
							contextInfo:NULL];
		
		return NSTerminateLater;
	}
	
	return NSTerminateNow;
}

- (void)connectionOpenAlertDidEnd:(NSAlert*)alert
					   returnCode:(NSInteger)returnCode
					  contextInfo:(void*)contextInfo
{
	// Ensure the sheet has closed
	[[alert window] orderOut:self];
	
	// Reply to the NSApplication instance, telling it whether or not to quit
	[NSApp replyToApplicationShouldTerminate:(returnCode == NSAlertFirstButtonReturn)];
}

#pragma mark -
#pragma mark NSWindow Delegate Methods

- (BOOL)windowShouldClose:(id)closingWindow
{
	[NSApp terminate:self];
	
	return NO;
}

#pragma mark -
#pragma mark Main Window Tabs

- (IBAction)switchToGameTab:(id)sender
{
	[tabView selectTabViewItemAtIndex:0];
}

- (IBAction)switchToChatTab:(id)sender
{
	[tabView selectTabViewItemAtIndex:1];
}

- (IBAction)switchToWinlistTab:(id)sender
{
	[tabView selectTabViewItemAtIndex:2];
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

- (void)openPreferencesTabNumber:(NSInteger)tabNumber
{
	[self showPreferences:self];
	[prefsWindowController displayViewControllerAtIndex:tabNumber];
}

- (IBAction)openGeneralPreferencesTab:(id)sender
{
	[self openPreferencesTabNumber:generalPreferencesTab];
}

- (IBAction)openThemesPreferencesTab:(id)sender
{
	[self openPreferencesTabNumber:themesPreferencesTab];
}

- (IBAction)openServersPreferencesTab:(id)sender
{
	[self openPreferencesTabNumber:serversPreferencesTab];
}

- (IBAction)openKeyboardPreferencesTab:(id)sender
{
	[self openPreferencesTabNumber:keyboardPreferencesTab];
}

#pragma mark -
#pragma mark Accessors

@synthesize window;

- (iTetPreferencesController*)prefs
{
	return [iTetPreferencesController preferencesController];
}

@end
