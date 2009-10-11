//
//  iTetThemesViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import <Cocoa/Cocoa.h>

@class iTetThemesArrayController;
@class iTetPreferencesController;

@interface iTetThemesViewController : NSViewController
{
	IBOutlet iTetThemesArrayController* themesArrayController;
}

+ (id)viewController;

- (IBAction)addTheme:(id)sender;
- (IBAction)chooseTheme:(id)sender;

@property (readonly) iTetPreferencesController* preferencesController;

@end
