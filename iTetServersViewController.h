//
//  iTetServersViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/5/09.
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
