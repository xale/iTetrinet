//
//  iTetPreferencesWindowController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetPreferencesViewController;

typedef enum
{
	noPreferencesTab =			-1,
	generalPreferencesTab =		0,
	themesPreferencesTab =		1,
	serversPreferencesTab =		2,
	keyboardPreferencesTab =	3
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
