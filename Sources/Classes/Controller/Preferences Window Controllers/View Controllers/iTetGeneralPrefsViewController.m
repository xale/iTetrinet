//
//  iTetGeneralPrefsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGeneralPrefsViewController.h"

#define iTetGeneralPreferencesViewName	NSLocalizedStringFromTable(@"preferences.general", @"PreferencePanes", @"Title of the 'general preferences' preferences pane")

@implementation iTetGeneralPrefsViewController

- (id)init
{
	if (![super initWithNibName:@"GeneralPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:iTetGeneralPreferencesViewName];
	
	return self;
}

@end
