//
//  iTetKeyboardViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetKeyboardViewController.h"
#import "iTetPreferencesController.h"
#import "iTetKeyView.h"

@implementation iTetKeyboardViewController

+ (id)viewController
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if (![super initWithNibName:@"KeyboardPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:@"Keyboard Controls"];
	
	return self;
}

- (void)awakeFromNib
{
	// Set the active keyboard configuration in the pop-up menu
	// FIXME: WRITEME: keyboard configurations
	
	// Set the active keys in the key views
	// FIXME: WRITEME: keyboard 
}

#pragma mark -
#pragma mark iTetKeyView Delegate Methods

- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedKey:(NSEvent*)keyEvent
{
	// FIXME: WRITEME
	return YES;
}
- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedModifier:(NSEvent*)modifierEvent
{
	// FIXME: WRITEME
	return YES;
}

- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(NSEvent*)keyEvent
{
	// FIXME: WRITEME
}
- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedModifier:(NSEvent*)modifierEvent
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Accessors

- (iTetPreferencesController*)preferencesController
{
	return [iTetPreferencesController preferencesController];
}

@end
