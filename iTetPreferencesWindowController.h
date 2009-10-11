//
//  iTetPreferencesWindowController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	generalPreferencesTab = 0,
	themesPreferencesTab,
	serversPreferencesTab
} iTetPreferencesTabNumber;

@interface iTetPreferencesWindowController : NSWindowController
{
	NSArray* viewControllers;
	NSInteger currentViewNumber;
	
	IBOutlet NSBox* viewBox;
	
	IBOutlet NSToolbarItem* general;
	IBOutlet NSToolbarItem* themes;
	IBOutlet NSToolbarItem* servers;
}

- (IBAction)changeView:(id)sender;
- (void)displayViewControllerAtIndex:(iTetPreferencesTabNumber)index;

- (NSArray*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar;

@end
