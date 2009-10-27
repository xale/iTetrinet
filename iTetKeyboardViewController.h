//
//  iTetKeyboardViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import <Cocoa/Cocoa.h>

@class iTetPreferencesController;
@class iTetKeyView;

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

+ (id)viewController;

- (void)startObservingKeyView:(iTetKeyView*)keyView;
- (void)stopObservingKeyView:(iTetKeyView*)keyView;

- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedKey:(NSEvent*)keyEvent;
- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedModifier:(NSEvent*)modifierEvent;

- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(NSEvent*)keyEvent;
- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedModifier:(NSEvent*)modifierEvent;

- (void)setKeyDescriptionForKeyView:(iTetKeyView*)keyView;

@property (readonly) iTetPreferencesController* preferencesController;

@end
