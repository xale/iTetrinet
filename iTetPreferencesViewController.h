//
//  iTetPreferencesViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/23/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetPreferencesController.h"

@class iTetPreferencesController;

#define PREFS [iTetPreferencesController preferencesController]

@interface iTetPreferencesViewController : NSViewController
{
	
}

+ (id)viewController;

@property (readonly) iTetPreferencesController* prefs;

@end
