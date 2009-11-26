//
//  iTetPreferencesWindowController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import <Cocoa/Cocoa.h>

@class iTetPreferencesViewController;

typedef enum
{
	noPreferencesTab = -1,
	generalPreferencesTab =	0,
	themesPreferencesTab,
	serversPreferencesTab,
	keyboardPreferencesTab
} iTetPreferencesTabNumber;

@interface iTetPreferencesWindowController : NSWindowController
{
	NSArray* viewControllers;
	NSInteger currentViewNumber;
	
	IBOutlet NSBox* viewBox;
	
	IBOutlet NSToolbarItem* general;
	IBOutlet NSToolbarItem* themes;
	IBOutlet NSToolbarItem* servers;
	IBOutlet NSToolbarItem* keyboard;
}

- (IBAction)changeView:(id)sender;
- (void)displayViewControllerAtIndex:(iTetPreferencesTabNumber)index;
- (void)displayViewController:(iTetPreferencesViewController*)controller;

- (NSArray*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar;

@end
