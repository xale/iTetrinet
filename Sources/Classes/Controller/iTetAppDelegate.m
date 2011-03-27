//
//  iTetAppDelegate.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetAppDelegate.h"
#import "iTetMainWindowController.h"
#import "iTetPreferencesWindowController.h"
#import "iTetGrowlController.h"

@implementation iTetAppDelegate

- (void)dealloc
{
	[mainWindowController release];
	[preferencesWindowController release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)showPreferences:(id)sender
{
	// Create the preferences window controller, if none exists
	if (preferencesWindowController == nil)
		preferencesWindowController = [[iTetPreferencesWindowController alloc] init];
	
	// Display the preferences window
	[preferencesWindowController showWindow:self];
	[[preferencesWindowController window] makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark NSApplication Delegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	// Load and display the main window
	mainWindowController = [[iTetMainWindowController alloc] init];
	[mainWindowController showWindow:self];
	
	// Set up the Growl application bridge
	[GrowlApplicationBridge setGrowlDelegate:[iTetGrowlController sharedGrowlController]];
}

@end
