//
//  iTetPreferencesViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/23/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetPreferencesController.h"
#import "iTetPreferencesWindowController.h"

#define PREFS [iTetPreferencesController preferencesController]

@interface iTetPreferencesViewController : NSViewController

+ (id)viewController;

- (BOOL)viewShouldBeSwappedForView:(iTetPreferencesViewController*)newController
		    byWindowController:(iTetPreferencesWindowController*)sender;
- (void)viewWillBeRemoved:(id)sender;
- (void)viewWasSwappedIn:(id)sender;

@property (readonly) iTetPreferencesController* prefs;

@end
