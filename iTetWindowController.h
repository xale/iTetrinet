//
//  iTetWindowController.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetNetworkController;
@class iTetPlayersController;
@class iTetPreferencesWindowController;

extern NSString* const iTetWindowControllerSelectedTabViewItemDidChangeNotification;
extern NSString* const iTetGameViewTabIdentifier;
extern NSString* const iTetChatViewTabIdentifier;
extern NSString* const iTetWinlistViewTabIdentifier;

@interface iTetWindowController : NSObject
{
	// Main window
	IBOutlet NSWindow* window;
	
	// Main tab view
	IBOutlet NSTabView* tabView;
	
	// Top-level controllers
	IBOutlet iTetNetworkController* networkController;
	IBOutlet iTetPlayersController* playersController;
	
	// Preferences window
	iTetPreferencesWindowController* prefsWindowController;
}

- (IBAction)switchToGameTab:(id)sender;
- (IBAction)switchToChatTab:(id)sender;
- (IBAction)switchToWinlistTab:(id)sender;

- (IBAction)showPreferences:(id)sender;
- (void)openPreferencesTabNumber:(NSInteger)tabNumber;
- (IBAction)openGeneralPreferencesTab:(id)sender;
- (IBAction)openThemesPreferencesTab:(id)sender;
- (IBAction)openServersPreferencesTab:(id)sender;
- (IBAction)openKeyboardPreferencesTab:(id)sender;

@property (readonly) NSWindow* window;
@property (readonly) NSTabView* tabView;

@end
