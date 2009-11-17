//
//  iTetKeyboardViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import <Cocoa/Cocoa.h>

@class iTetPreferencesController;
@class iTetKeyView;
@class iTetKeyNamePair;

@interface iTetKeyboardViewController : NSViewController
{
	IBOutlet NSPopUpButton* configurationPopUpButton;
	
	IBOutlet iTetKeyView* moveLeftKeyView;
	IBOutlet iTetKeyView* moveRightKeyView;
	IBOutlet iTetKeyView* rotateCounterclockwiseKeyView;
	IBOutlet iTetKeyView* rotateClockwiseKeyView;
	IBOutlet iTetKeyView* moveDownKeyView;
	IBOutlet iTetKeyView* dropKeyView;
	IBOutlet iTetKeyView* gameChatKeyView;
	
	IBOutlet NSTextField* keyDescriptionField;
}

- (IBAction)changeConfiguration:(id)sender;
- (IBAction)saveConfiguration:(id)sender;
- (IBAction)deleteConfiguration:(id)sender;

+ (id)viewController;

- (void)startObservingKeyView:(iTetKeyView*)keyView;
- (void)stopObservingKeyView:(iTetKeyView*)keyView;

- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedKey:(iTetKeyNamePair*)key;

- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(iTetKeyNamePair*)key;

- (void)setKeyDescriptionForKeyView:(iTetKeyView*)keyView;

@property (readonly) iTetPreferencesController* preferencesController;

@end
