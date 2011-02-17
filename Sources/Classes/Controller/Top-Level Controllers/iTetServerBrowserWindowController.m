//
//  iTetServerBrowserWindowController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/11.
//  Copyright 2011 Indie Pennant Software. All rights reserved.
//

#import "iTetServerBrowserWindowController.h"

#import "iTetServerListEntry.h"
#import "iTetUserDefaults.h"

#import "IPSContextMenuTableView.h"

NSString* const iTetServerBrowserWindowNibName =	@"ServerBrowserWindow";

@implementation iTetServerBrowserWindowController

+ (void)initialize
{
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[iTetServerListEntry defaultFavoriteServers]]
				 forKey:iTetFavoriteServersPrefKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

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

#define iTetConnectWithOfflineGameInProgressAlertInformativeText	NSLocalizedStringFromTable(@"An offline game is currently in progress. Before you can connect to a server, you will have to forfeit the game. Are you sure you want to do this?", @"NetworkController", @"Informative text on alert displayed when the user attempts to open a new server connection while playing an offline game")
#define iTetConnectWithOfflineGameInProgressConfirmButtonTitle		NSLocalizedStringFromTable(@"Forfeit Game", @"NetworkController", @"Title of button on 'connect with offline game in progress?' alert that allows the user to stop playing the offline game and open a connection to a server")

- (IBAction)connect:(id)sender
{
	// FIXME: WRITEME: determine selected server, connect
	
	// Check if the user is playing an offline game
	/* FIXME: re-enable when connection code is written
	 if ([gameController gameInProgress])
	{
		// Make note if the game was paused, pause if not
		BOOL gameWasPaused = ([gameController gameplayState] == gamePaused);
		if (!gameWasPaused)
			[gameController pauseGame];
		
		// If the user is playing an offline game, create an alert asking to end the game before connecting
		NSAlert* alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:iTetGameInProgressAlertTitle];
		[alert setInformativeText:iTetConnectWithOfflineGameInProgressAlertInformativeText];
		[alert addButtonWithTitle:iTetConnectWithOfflineGameInProgressConfirmButtonTitle];
		[alert addButtonWithTitle:iTetContinuePlayingButtonTitle];
		
		// Run the alert as sheet
		[alert beginSheetModalForWindow:[windowController window]
						  modalDelegate:self
						 didEndSelector:@selector(connectWithOfflineGameInProgressAlertDidEnd:returnCode:gameWasPaused:)
							contextInfo:[[NSNumber alloc] initWithBool:gameWasPaused]];
	}*/
}

- (void)connectWithOfflineGameInProgressAlertDidEnd:(NSAlert*)alert
										 returnCode:(NSInteger)returnCode
									  gameWasPaused:(NSNumber*)pauseState
{
	/* FIXME: re-enable when we have a way to access the game state
	BOOL gameWasPaused = [pauseState boolValue];
	[pauseState release];
	
	// Order out the sheet
	[[alert window] orderOut:self];
	
	// If the user pressed "continue playing", resume the game
	if (returnCode == NSAlertSecondButtonReturn)
	{
		// If the game was not paused beforehand, resume the game
		if (!gameWasPaused)
			[gameController resumeGame];
		
		return;
	}
	
	// Otherwise, tell the game controller to end the game
	[gameController endGame];
	 */
	 
	// Open the connection
	// FIXME: WRITEME: open connection
}

- (IBAction)refreshServerList:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)addNewServerToFavorites:(id)sender
{
	// FIXME: WRITEME: add new server list entry to favorites controller, select "address" field
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

NSString* const iTetServerBrowserWindowInternetServersTabIdentifier =	@"internet";
NSString* const iTetServerBrowserWindowFavoriteServersTabIdentifier =	@"favorites";

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item
{
	// Determine the item's action
	SEL action = [item action];
	
	// "Connect to server"
	if (action == @selector(connect:))
	{
		// Check which tab of the browser is open
		NSArrayController* activeController = nil;
		if ([[[browserTabView selectedTabViewItem] identifier] isEqualToString:iTetServerBrowserWindowInternetServersTabIdentifier])
			activeController = internetServersController;
		else if ([[[browserTabView selectedTabViewItem] identifier] isEqualToString:iTetServerBrowserWindowFavoriteServersTabIdentifier])
			activeController = favoriteServersController;
		
		// Check that the active controller has exactly one server selected
		if ([[favoriteServersController selectedObjects] count] != 1)
			return NO;
		
		// FIXME: WRITEME: check the player's nickname and team name
		
		return YES;
	}
	
	// By default, make the control active
	return YES;
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
