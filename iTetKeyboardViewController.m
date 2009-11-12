//
//  iTetKeyboardViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetKeyboardViewController.h"
#import "iTetPreferencesController.h"
#import "iTetKeyView.h"
#import "iTetKeyNamePair.h"

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
	// FIXME: WRITEME: keys for key views
	
	// Register for notifications when a key view changes highlight state
	[self startObservingKeyView:moveLeftKeyView];
	[self startObservingKeyView:moveRightKeyView];
	[self startObservingKeyView:rotateCounterclockwiseKeyView];
	[self startObservingKeyView:rotateClockwiseKeyView];
	[self startObservingKeyView:moveDownKeyView];
	[self startObservingKeyView:dropKeyView];
	[self startObservingKeyView:gameChatKeyView];
	
	// Clear the description text
	[keyDescriptionField setStringValue:@""];
}

- (void)dealloc
{
	// Stop observing key view highlight states
	[self stopObservingKeyView:moveLeftKeyView];
	[self stopObservingKeyView:moveRightKeyView];
	[self stopObservingKeyView:rotateCounterclockwiseKeyView];
	[self stopObservingKeyView:rotateClockwiseKeyView];
	[self stopObservingKeyView:moveDownKeyView];
	[self stopObservingKeyView:dropKeyView];
	[self stopObservingKeyView:gameChatKeyView];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Key-Value Observing

- (void)startObservingKeyView:(iTetKeyView*)keyView
{
	[keyView addObserver:self
		    forKeyPath:@"highlighted"
			 options:NSKeyValueObservingOptionNew
			 context:NULL];
}

- (void)stopObservingKeyView:(iTetKeyView*)keyView
{
	[keyView removeObserver:self
			 forKeyPath:@"highlighted"];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
			    ofObject:(id)object
				change:(NSDictionary*)changeDict
			     context:(void*)context
{
	// If this isn't a key view, we don't care (and we shouldn't be getting
	// this notification...)
	if (![object isKindOfClass:[iTetKeyView class]])
		return;
	
	// Cast to a key view
	iTetKeyView* keyView = (iTetKeyView*)object;
	
	// Determine whether the view is highlighted
	if ([[changeDict objectForKey:NSKeyValueChangeNewKey] boolValue])
	{
		// Key view is now highlighted: set the description text to that
		// key view's description
		[self setKeyDescriptionForKeyView:keyView];
	}
}

#pragma mark -
#pragma mark iTetKeyView Delegate Methods

- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedKey:(iTetKeyNamePair*)key
{
	// FIXME: WRITEME
	return YES;
}

- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(iTetKeyNamePair*)key
{
	// FIXME: WRITEME
	
	// Clear the text field
	[keyDescriptionField setStringValue:@""];
}

#pragma mark -
#pragma mark Accessors

NSString* const iTetKeyDescriptionFormat = @"Press a key to bind to \'%@\'";

- (void)setKeyDescriptionForKeyView:(iTetKeyView*)keyView
{
	[keyDescriptionField setStringValue:
	 [NSString stringWithFormat:iTetKeyDescriptionFormat, [keyView actionName]]];
}

- (iTetPreferencesController*)preferencesController
{
	return [iTetPreferencesController preferencesController];
}

@end
