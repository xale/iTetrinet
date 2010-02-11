//
//  iTetAppController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import <Cocoa/Cocoa.h>

@class iTetNetworkController;
@class iTetPreferencesController;
@class iTetGameViewController;
@class iTetChatViewController;
@class iTetWinlistViewController;
@class iTetTextAttributesController;
@class iTetPlayer;
@class iTetLocalPlayer;
@class iTetPreferencesWindowController;

#define ITET_MAX_PLAYERS	(6)

@interface iTetAppController : NSObject <NSUserInterfaceValidations>
{
	// Main window
	IBOutlet NSWindow* window;
	
	// Main tab view
	IBOutlet NSTabView* tabView;
	
	// View Controllers
	IBOutlet iTetGameViewController* gameController;
	IBOutlet iTetChatViewController* chatController;
	IBOutlet iTetWinlistViewController* winlistController;
	
	// Miscellaneous Controllers
	IBOutlet iTetTextAttributesController* textAttributesController;
	
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
	NSInteger playerCount;
	iTetLocalPlayer* localPlayer;
	
	// Preferences window
	iTetPreferencesWindowController* prefsWindowController;
}

- (IBAction)openCloseConnection:(id)sender;
- (IBAction)startStopGame:(id)sender;
- (IBAction)forfeitGame:(id)sender;
- (IBAction)pauseResumeGame:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (void)openPreferencesTabNumber:(NSInteger)tabNumber;
- (IBAction)switchToGameTab:(id)sender;
- (IBAction)switchToChatTab:(id)sender;
- (IBAction)switchToWinlistTab:(id)sender;

- (void)connectionOpened;
- (void)connectionClosed;
- (void)connectionError:(NSError*)error;
- (void)messageRecieved:(NSData*)message;

- (void)setLocalPlayerNumber:(NSInteger)number;
- (void)addPlayerWithNumber:(NSInteger)number
			 nickname:(NSString*)nick;
- (void)removePlayerNumber:(NSInteger)number;
- (void)removeAllPlayers;
- (iTetPlayer*)playerNumber:(NSInteger)number;
- (NSString*)playerNameForNumber:(NSInteger)number;

@property (readonly) NSArray* playerList;
@property (readwrite, retain) iTetLocalPlayer* localPlayer;
@property (readonly) iTetPlayer* remotePlayer1;
@property (readonly) iTetPlayer* remotePlayer2;
@property (readonly) iTetPlayer* remotePlayer3;
@property (readonly) iTetPlayer* remotePlayer4;
@property (readonly) iTetPlayer* remotePlayer5;
- (iTetPlayer*)remotePlayerNumber:(NSInteger)n;

@property (readonly) iTetNetworkController* networkController;
@property (readonly) iTetPreferencesController* preferencesController;

@end
