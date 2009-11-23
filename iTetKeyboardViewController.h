//
//  iTetKeyboardViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetPreferencesViewController.h"

@class iTetKeyView;
@class iTetKeyNamePair;

@interface iTetKeyboardViewController : iTetPreferencesViewController
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
	
	IBOutlet NSWindow* saveSheetWindow;
	IBOutlet NSTextField* configurationNameField;
	IBOutlet NSButton* saveButton;
	
	NSMutableDictionary* unsavedConfiguration;
}

- (IBAction)changeConfiguration:(id)sender;
- (IBAction)saveConfiguration:(id)sender;
- (IBAction)closeSaveSheet:(id)sender;
- (IBAction)deleteConfiguration:(id)sender;

- (void)insertConfiguration:(NSMutableDictionary*)config
	   inPopUpMenuAtIndex:(NSUInteger)index
			tagNumber:(NSUInteger)tag;
- (void)displayConfigurationNumber:(NSUInteger)configNum;
- (void)clearUnsavedConfiguration;

- (void)startObservingKeyView:(iTetKeyView*)keyView;
- (void)stopObservingKeyView:(iTetKeyView*)keyView;

- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedKey:(iTetKeyNamePair*)key;

- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(iTetKeyNamePair*)key;

- (void)setKeyDescriptionForKeyView:(iTetKeyView*)keyView;

- (NSMutableDictionary*)keyConfigNumber:(NSUInteger)configNum;

@end
