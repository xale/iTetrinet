//
//  iTetServersViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetPreferencesViewController.h"

@interface iTetServersViewController : iTetPreferencesViewController
{
	IBOutlet NSTableView* serversTableView;
	IBOutlet NSArrayController* serversArrayController;
}

- (IBAction)createServer:(id)sender;

@property (readonly) NSArray* valuesForProtocolPopUpCell;

@end
