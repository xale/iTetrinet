//
//  iTetWindowController.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/10.
//

#import <Cocoa/Cocoa.h>

@class iTetPreferencesController;
@class iTetPreferencesWindowController;

@interface iTetWindowController : NSObject
{
	// Main window
	IBOutlet NSWindow* window;
	
	// Main tab view
	IBOutlet NSTabView* tabView;
	
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
@property (readonly) iTetPreferencesController* prefs;

@end
