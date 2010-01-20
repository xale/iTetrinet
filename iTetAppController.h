//
//  iTetAppController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import <Cocoa/Cocoa.h>

@class iTetNetworkController;
@class iTetPreferencesController;
@class iTetChatViewController;
@class iTetGameViewController;
@class iTetPlayer;
@class iTetLocalPlayer;
@class iTetPreferencesWindowController;

#define ITET_MAX_PLAYERS	(6)

@interface iTetAppController : NSObject <NSUserInterfaceValidations>
{
	// Window
	IBOutlet NSWindow* window;
	
	// View Controllers
	IBOutlet iTetChatViewController* chatController;
	IBOutlet iTetGameViewController* gameController;
	
	// List view (and controller) for servers on connection sheet
	IBOutlet NSScrollView* serverListView;
	IBOutlet NSArrayController* serverListController;
	
	// Menu and toolbar items
	IBOutlet NSToolbarItem* connectionButton;
	IBOutlet NSMenuItem* connectionMenuItem;
	IBOutlet NSToolbarItem* gameButton;
	IBOutlet NSMenuItem* gameMenuItem;
	IBOutlet NSToolbarItem* pauseButton;
	IBOutlet NSMenuItem* pauseMenuItem;
	
	// Connection progress indicator
	IBOutlet NSProgressIndicator* connectionProgressIndicator;
	IBOutlet NSTextField* connectionStatusLabel;
	
	// Network
	iTetNetworkController* networkController;
	NSTimer* connectionTimer;
	
	// Players
	NSMutableArray* players;
	int playerCount;
	iTetLocalPlayer* localPlayer;
	
	// Preferences window
	iTetPreferencesWindowController* prefsWindowController;
}

- (IBAction)openCloseConnection:(id)sender;
- (IBAction)startStopGame:(id)sender;
- (IBAction)pauseResumeGame:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (void)openPreferencesTabNumber:(NSInteger)tabNumber;

- (void)connectionOpened;
- (void)connectionClosed;
- (void)connectionError:(NSError*)error;
- (void)messageRecieved:(NSString*)message;

- (void)setLocalPlayerNumber:(int)number;
- (void)addPlayerWithNumber:(int)number
			 nickname:(NSString*)nick;
- (void)setTeamName:(NSString*)team
    forPlayerNumber:(int)number;
- (void)removePlayerNumber:(int)number;
- (void)removeAllPlayers;
- (NSString*)playerNameForNumber:(int)number;

@property (readonly) NSArray* playerList;
@property (readwrite, retain) iTetLocalPlayer* localPlayer;

@property (readonly) iTetNetworkController* networkController;
@property (readonly) iTetPreferencesController* preferencesController;

@end
