//
//  iTetThemesViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetPreferencesViewController.h"

@class iTetThemesArrayController;

@interface iTetThemesViewController : iTetPreferencesViewController
{
	IBOutlet iTetThemesArrayController* themesArrayController;
	IBOutlet NSCollectionView* themesCollectionView;
	IBOutlet NSScrollView* themesScrollView;
	NSIndexSet* initialThemeSelection;
}

- (IBAction)addTheme:(id)sender;

@end
