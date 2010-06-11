//
//  iTetGeneralPrefsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetGeneralPrefsViewController.h"

#define iTetGeneralPreferencessViewName	NSLocalizedStringFromTable(@"General Preferences", @"PreferencePanes", @"Title of the 'general preferences' preferences pane")

@implementation iTetGeneralPrefsViewController

- (id)init
{
	if (![super initWithNibName:@"GeneralPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:iTetGeneralPreferencessViewName];
	
	return self;
}

@end
