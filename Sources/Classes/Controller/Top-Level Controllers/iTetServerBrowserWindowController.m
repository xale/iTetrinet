//
//  iTetServerBrowserWindowController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/11.
//  Copyright 2011 Indie Pennant Software. All rights reserved.
//

#import "iTetServerBrowserWindowController.h"

NSString* const iTetServerBrowserWindowNibName =	@"ServerBrowserWindow";

@implementation iTetServerBrowserWindowController

- (id)init
{
	return [super initWithWindowNibName:iTetServerBrowserWindowNibName];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	
	// FIXME: WRITEME: populate favorites list, start a refresh
}

- (IBAction)connect:(id)sender
{
	// FIXME: WRITEME: determine selected server, connect
}

- (IBAction)refreshServerList:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)addSelectedServersToFavorites:(id)sender
{
	// Add the servers selected in the "internet servers" table to the favorites list
	for (iTetServerListEntry* server in [internetServersController selectedObjects])
	{
		// Check that the server is not already a favorite
		if ([[favoriteServersController content] containsObject:server])
			continue;
		
		// Add the server to favorites
		[favoriteServersController addObject:server];
	}
}

#pragma mark -
#pragma mark NSUserInterfaceValidations Methods

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark NSWindow Delegate Methods

- (void)windowWillClose:(NSNotification*)notification
{
	// FIXME: WRITEME: write favorite servers to user defaults
}

#pragma mark -
#pragma mark IPSContextMenuTableView Delegate Methods

#define iTetServerBrowserRightClickActionsMenuTitle	NSLocalizedStringFromTable(@"Server Actions", @"ServerBrowserController", @"Title of the contextual menu displayed when the user right- or control-clicks on a server in the server browser table view")
#define iTetAddServerToFavoritesMenuItemTitle		NSLocalizedStringFromTable(@"Add to Favorites", @"ServerBrowserController", @"Title of the menu item in the server browser contextual menu that allows the user to add a server to their list of favorite servers")
#define iTetRefreshServerListMenuItemTitle			NSLocalizedStringFromTable(@"Refresh Server List", @"ServerBrowserController", @"Title of the menu item in the server browser contextual menu that allows the user to refresh the list of servers")

- (NSMenu*)tableView:(IPSContextMenuTableView*)tableView
		menuForEvent:(NSEvent*)event
{
	// Create a menu
	NSMenu* menu = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:iTetServerBrowserRightClickActionsMenuTitle] autorelease];
	[menu setAutoenablesItems:NO];
	
	// Create a "add to favorites" menu item
	NSMenuItem* menuItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:iTetAddServerToFavoritesMenuItemTitle
																				 action:@selector(addSelectedServersToFavorites:)
																		  keyEquivalent:@""] autorelease];
	[menuItem setTarget:self];
	[menu addItem:menuItem];
	
	// If the table view doesn't have a row selected, disable the "add to favorites" item
	[menuItem setEnabled:([tableView numberOfSelectedRows] == 1)];
	
	// Create a "refresh server list" menu item
	menuItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:iTetRefreshServerListMenuItemTitle
																	 action:@selector(refreshServerList:)
															  keyEquivalent:@""] autorelease];
	[menuItem setTarget:self];
	[menu addItem:menuItem];
	
	return menu;
}

#pragma mark -
#pragma mark Accessors

@synthesize refreshingServerList;

@end
