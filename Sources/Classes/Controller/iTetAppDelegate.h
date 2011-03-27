//
//  iTetAppDelegate.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetMainWindowController;
@class iTetPreferencesWindowController;

@interface iTetAppDelegate : NSObject
{
	iTetMainWindowController* mainWindowController;
	iTetPreferencesWindowController* preferencesWindowController;
}

- (IBAction)showPreferences:(id)sender;

@end
