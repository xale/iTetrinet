//
//  iTetGeneralPrefsViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import <Cocoa/Cocoa.h>

@class iTetPreferencesController;

@interface iTetGeneralPrefsViewController : NSViewController
{

}

+ (id)viewController;

@property (readonly) iTetPreferencesController* preferencesController;

@end
