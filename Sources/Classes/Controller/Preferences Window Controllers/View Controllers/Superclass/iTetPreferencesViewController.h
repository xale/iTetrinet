//
//  iTetPreferencesViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/23/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetPreferencesWindowController.h"

@interface iTetPreferencesViewController : NSViewController

+ (id)viewController;

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender;
- (BOOL)windowShouldClose:(id)window;
- (BOOL)viewShouldBeSwappedForView:(iTetPreferencesViewController*)newController
				byWindowController:(iTetPreferencesWindowController*)sender;
- (void)viewWillBeRemoved:(id)sender;
- (void)viewWasSwappedIn:(id)sender;


@end
