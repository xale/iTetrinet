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

NSString* const iTetGeneralPrefsViewNibName =	@"GeneralPrefsView";

#define iTetGeneralPreferencesViewName	NSLocalizedStringFromTable(@"General Preferences", @"PreferencePanes", @"Title of the 'general preferences' preferences pane")

@implementation iTetGeneralPrefsViewController

- (id)init
{
	if (!(self = [super initWithNibName:iTetGeneralPrefsViewNibName bundle:nil]))
		return nil;
	
	[self setTitle:iTetGeneralPreferencesViewName];
	
	return self;
}

@end
