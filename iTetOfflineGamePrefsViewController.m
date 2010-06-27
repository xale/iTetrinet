//
//  iTetOfflineGamePrefsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/25/10.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetOfflineGamePrefsViewController.h"

#define iTetOfflineGamePreferencesViewName	NSLocalizedStringFromTable(@"Offline Game Preferences", @"PreferencePanes", @"Title of the 'offline game preferences' preferences pane")

@implementation iTetOfflineGamePrefsViewController

- (id)init
{
	if (![super initWithNibName:@"OfflineGamePrefsView" bundle:nil])
		return nil;
	
	[self setTitle:iTetOfflineGamePreferencesViewName];
	
	return self;
}

@end
