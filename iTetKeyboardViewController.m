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
#import "NSMutableDictionary+KeyBindings.h"

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
	// Fill the pop-up menu with the available keyboard configurations
	NSArray* configurations = [[self preferencesController] keyConfigurations];
	int numConfigs = [configurations count];
	
	NSMenu* menu = [configurationPopUpButton menu];
	NSMenuItem* menuItem;
	for (int i = 0; i < numConfigs; i++)
	{
		NSString* configName = [[configurations objectAtIndex:i] configurationName];
		menuItem = [[NSMenuItem alloc] initWithTitle:configName
								  action:@selector(changeConfiguration:)
							 keyEquivalent:@""];
		[menuItem setTag:i];
		[menuItem setTarget:self];
		[menu addItem:menuItem];
		[menuItem release];
	}
	
	// Add a separator menu item to the pop-up menu
	[menu addItem:[NSMenuItem separatorItem]];
	
	// Add the "save configuration" menu item
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Save Configuration..."
							  action:@selector(saveConfiguration:)
						 keyEquivalent:@""];
	[menuItem setTarget:self];
	[menu addItem:menuItem];
	[menuItem release];
	
	// Add the "delete configuration" menu item
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Delete Configuration"
							  action:@selector(deleteConfiguration:)
						 keyEquivalent:@""];
	[menuItem setTarget:self];
	[menu addItem:menuItem];
	[menuItem release];
	
	// Select the active configuration in the pop-up menu
	NSUInteger currentConfigNum = [[self preferencesController] currentKeyConfigurationNumber];
	[configurationPopUpButton selectItemWithTag:currentConfigNum];
	
	// Display the active configuration in the key views
	[self displayConfigurationNumber:currentConfigNum];
	
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
#pragma mark Interface Actions

- (IBAction)changeConfiguration:(id)sender
{
	// Check if we have an unsaved configuration
	if (unsavedConfiguration)
	{
		// Create an alert
		NSAlert* alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Unsaved Configuration"];
		[alert setInformativeText:@"Your current key configuration is unsaved. If you change configurations, it will be lost. Do you  wish to save the configuration first?"];
		[alert addButtonWithTitle:@"Save Configuration"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert addButtonWithTitle:@"Change without Saving"];
		
		// Run the alert as a sheet
		[alert beginSheetModalForWindow:[[self view] window]
					modalDelegate:self
				     didEndSelector:@selector(unsavedConfigAlertDidEnd:returnCode:originalSender:)
					  contextInfo:sender];
		
		return;
	}
	
	// Switch to the selected configuration
	[self displayConfigurationNumber:[sender tag]];
}

- (void)unsavedConfigAlertDidEnd:(NSAlert*)alert
			    returnCode:(NSInteger)returnCode
			originalSender:(id)sender
{
	// If the user pressed "cancel", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// If the user pressed "change without saving", change configurations
	if (returnCode == NSAlertThirdButtonReturn)
	{
		[[alert window] orderOut:self];
		[self displayConfigurationNumber:[sender tag]];
		return;
	}
	
	// Otherwise, open the "save configuration" sheet
	[self saveConfiguration:self];
}

- (IBAction)saveConfiguration:(id)sender
{
	// FIXME: WRITEME: save current configuration
}

- (IBAction)deleteConfiguration:(id)sender
{
	// FIXME: WRITEME: delete current configuration
}

#pragma mark -
#pragma mark Configurations

- (void)displayConfigurationNumber:(NSUInteger)configNum
{
	// Set the new active configuration
	[[self preferencesController] setCurrentKeyConfigurationNumber:configNum];
	
	// Set the active keys in the key views
	NSMutableDictionary* currentConfig = [self keyConfigNumber:configNum];
	[moveLeftKeyView setRepresentedKey:
	 [currentConfig keyForAction:movePieceLeft]];
	[moveRightKeyView setRepresentedKey:
	 [currentConfig keyForAction:movePieceRight]];
	[rotateCounterclockwiseKeyView setRepresentedKey:
	 [currentConfig keyForAction:rotatePieceCounterclockwise]];
	[rotateClockwiseKeyView setRepresentedKey:
	 [currentConfig keyForAction:rotatePieceClockwise]];
	[moveDownKeyView setRepresentedKey:
	 [currentConfig keyForAction:movePieceDown]];
	[dropKeyView setRepresentedKey:
	 [currentConfig keyForAction:dropPiece]];
	[gameChatKeyView setRepresentedKey:
	 [currentConfig keyForAction:gameChat]];
	
	// We've just loaded a configuration, so it is obviously clean
	unsavedConfiguration = NO;
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
	else
	{
		// Key view is no longer highlighted: if the description text currently
		// contains the key's description, clear the text
		// FIXME: kinda hacky
		NSString* desc = [keyDescriptionField stringValue];
		if (([desc length] > 0) && ([desc characterAtIndex:0] == 'P'))
			[keyDescriptionField setStringValue:@""];
	}
}

#pragma mark -
#pragma mark iTetKeyView Delegate Methods

- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedKey:(iTetKeyNamePair*)key
{
	// Check if the pressed key is already in use
	NSMutableDictionary* currentConfig = [[self preferencesController] currentKeyConfiguration];
	iTetGameAction boundAction = [currentConfig actionForKey:key];
	if (boundAction != noAction)
	{
		// Place a warning in the text field
		[keyDescriptionField setStringValue:
		 [NSString stringWithFormat:@"\'%@\' is already bound to \"%@\"",
		  [key printedName], iTetNameForAction(boundAction)]];
		
		return NO;
	}
	
	return YES;
}

- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(iTetKeyNamePair*)key
{
	// FIXME: WRITEME
	
	// Mark the current configuration as dirty
	unsavedConfiguration = YES;
	
	// Clear the text field
	[keyDescriptionField setStringValue:@""];
}

#pragma mark -
#pragma mark Menu Item Validation

- (BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
	if ([menuItem action] == @selector(saveConfiguration:))
	{
		if (unsavedConfiguration)
			return YES;
		
		return NO;
	}
	
	if ([menuItem action] == @selector(deleteConfiguration:))
	{
		if (unsavedConfiguration)
			return NO;
		
		return YES;
	}
	
	return YES;
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

- (NSMutableDictionary*)keyConfigNumber:(NSUInteger)configNum
{	
	return [[[self preferencesController] keyConfigurations] objectAtIndex:configNum];
}

@end
