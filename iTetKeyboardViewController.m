//
//  iTetKeyboardViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetKeyboardViewController.h"

#import "iTetKeyView.h"
#import "iTetKeyNamePair.h"

#import "iTetUserDefaults.h"
#import "iTetKeyConfiguration.h"
#import "NSUserDefaults+AdditionalTypes.h"

#import "iTetCommonLocalizations.h"

#define iTetKeyboardPreferencesViewName					NSLocalizedStringFromTable(@"Keyboard Controls", @"KeyboardPrefsViewController", @"Title of 'keyboard configuration' preferences pane")
#define iTetUnsavedKeyboardConfigurationPlaceholderName	NSLocalizedStringFromTable(@"Unsaved Configuration", @"Keyboard", @"Placeholder name for copied keyboard configurations that have yet to be saved with a unique name")
#define iTetKeyDescriptionFormat						NSLocalizedStringFromTable(@"Press a key to bind to '%@'", @"KeyboardPrefsViewController", @"Format for the prompt for the user to bind a new key to a specified action")

NSString* const iTetOriginalSenderInfoKey =					@"originalSender";
NSString* const iTetNewControllerInfoKey =					@"newController";
NSString* const iTetWindowToCloseInfoKey =					@"windowToClose";

#define KEY_CONFIGS			[[NSUserDefaults standardUserDefaults] unarchivedObjectForKey:iTetKeyConfigsListPrefKey]
#define CURRENT_CONFIG_NUM	[[NSUserDefaults standardUserDefaults] unsignedIntegerForKey:iTetCurrentKeyConfigNumberPrefKey]

@interface iTetKeyboardViewController (Private)

- (void)insertConfiguration:(iTetKeyConfiguration*)config
		 inPopUpMenuAtIndex:(NSUInteger)index
				  tagNumber:(NSUInteger)tag;
- (void)displayConfigurationNumber:(NSUInteger)configNum;
- (void)clearUnsavedConfiguration;

- (void)startObservingKeyView:(iTetKeyView*)keyView;
- (void)stopObservingKeyView:(iTetKeyView*)keyView;

- (void)setKeyDescriptionForKeyView:(iTetKeyView*)keyView;

@end

@implementation iTetKeyboardViewController

+ (id)viewController
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if (![super initWithNibName:@"KeyboardPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:iTetKeyboardPreferencesViewName];
	
	return self;
}

#define iTetSaveKeyboardConfigurationMenuTitle		NSLocalizedStringFromTable(@"Save Current Configuration...", @"KeyboardPrefsViewController", @"Title of menu item used to save the active keyboard configurations")
#define iTetDeleteKeyboardConfigurationMenuTitle	NSLocalizedStringFromTable(@"Delete Current Configuration", @"KeyboardPrefsViewController", @"Title of menu item used to delete the active keyboard configuration")

- (void)awakeFromNib
{
	// Set the actions associated with the key views
	[moveLeftKeyView setAssociatedAction:movePieceLeft];
	[moveRightKeyView setAssociatedAction:movePieceRight];
	[rotateCounterclockwiseKeyView setAssociatedAction:rotatePieceCounterclockwise];
	[rotateClockwiseKeyView setAssociatedAction:rotatePieceClockwise];
	[moveDownKeyView setAssociatedAction:movePieceDown];
	[dropKeyView setAssociatedAction:dropPiece];
	[discardSpecialKeyView setAssociatedAction:discardSpecial];
	[selfSpecialKeyView setAssociatedAction:selfSpecial];
	[gameChatKeyView setAssociatedAction:gameChat];
	[useSpecialOnPlayer1KeyView setAssociatedAction:specialPlayer1];
	[useSpecialOnPlayer2KeyView setAssociatedAction:specialPlayer2];
	[useSpecialOnPlayer3KeyView setAssociatedAction:specialPlayer3];
	[useSpecialOnPlayer4KeyView setAssociatedAction:specialPlayer4];
	[useSpecialOnPlayer5KeyView setAssociatedAction:specialPlayer5];
	[useSpecialOnPlayer6KeyView setAssociatedAction:specialPlayer6];
	
	// Add the key views to an array for easy enumeration
	keyViews = [[NSArray alloc] initWithObjects:
				moveLeftKeyView,
				moveRightKeyView,
				rotateCounterclockwiseKeyView,
				rotateClockwiseKeyView,
				moveDownKeyView,
				dropKeyView,
				discardSpecialKeyView,
				selfSpecialKeyView,
				gameChatKeyView,
				useSpecialOnPlayer1KeyView,
				useSpecialOnPlayer2KeyView,
				useSpecialOnPlayer3KeyView,
				useSpecialOnPlayer4KeyView,
				useSpecialOnPlayer5KeyView,
				useSpecialOnPlayer6KeyView,
				nil];
	
	// Register for notifications when a key view changes highlight state
	for (iTetKeyView* keyView in keyViews)
	{
		[self startObservingKeyView:keyView];
	}
	
	// Fill the pop-up menu with the available keyboard configurations
	NSArray* configurations = KEY_CONFIGS;
	NSUInteger numConfigs = [configurations count];
	for (NSUInteger index = 0; index < numConfigs; index++)
	{
		[self insertConfiguration:[configurations objectAtIndex:index]
			   inPopUpMenuAtIndex:index
						tagNumber:index];
	}
	
	// Add a separator menu item to the pop-up menu
	[[configurationPopUpButton menu] addItem:[NSMenuItem separatorItem]];
	
	// Add the "save configuration" menu item
	NSMenuItem* menuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:iTetSaveKeyboardConfigurationMenuTitle
																				action:@selector(saveConfiguration:)
																		 keyEquivalent:@""];
	[menuItem setTarget:self];
	[[configurationPopUpButton menu] addItem:menuItem];
	[menuItem release];
	
	// Add the "delete configuration" menu item
	menuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:iTetDeleteKeyboardConfigurationMenuTitle
																	action:@selector(deleteConfiguration:)
															 keyEquivalent:@""];
	[menuItem setTarget:self];
	[[configurationPopUpButton menu] addItem:menuItem];
	[menuItem release];
	
	// Display the active configuration in the key views
	[self displayConfigurationNumber:CURRENT_CONFIG_NUM];
	
	// Clear the description text
	[keyDescriptionField setStringValue:[NSString string]];
	displayingPrompt = NO;
}

- (void)dealloc
{
	// If we have an unsaved configuration, release it
	[unsavedConfiguration release];
	
	// Stop observing key view highlight states
	for (iTetKeyView* keyView in keyViews)
	{
		[self stopObservingKeyView:keyView];
	}
	
	// Release the array of key views
	[keyViews release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

#define iTetUnsavedKeyboardConfigurationAlertTitle						NSLocalizedStringFromTable(@"Unsaved Keyboard Configuration", @"KeyboardPrefsViewController", @"Title of the alert displayed when the user attempts to change keyboard configurations or dismiss the view while the active configuration is unsaved")
#define iTetChangeWithUnsavedKeyboardConfigurationAlertInformativeText	NSLocalizedStringFromTable(@"Your current key configuration is unsaved. If you change configurations, it will be lost. Do you  wish to save the configuration first?", @"KeyboardPrefsViewController", @"Informative text explaining the alert when the user attempts to change keyboard configurations while the active configuration is unsaved")
#define iTetSaveKeyboardConfigurationButtonTitle						NSLocalizedStringFromTable(@"Save Configuration", @"KeyboardPrefsViewController", @"Title of button displayed on the 'change keyboard configuration or dismiss view with unsaved configuration' alert that allows the user to save the unsaved configuration")
#define iTetChangeWithoutSavingKeyboardConfigurationButtonTitle			NSLocalizedStringFromTable(@"Change without Saving", @"KeyboardPrefsViewController", @"Title of button displayed on the 'change keyboard configuration with unsaved configuration' alert that allows the user to switch configurations without saving")

- (IBAction)changeConfiguration:(id)sender
{
	// Check if we have an unsaved configuration
	if (unsavedConfiguration != nil)
	{
		// Create an alert
		NSAlert* alert = [[NSAlert alloc] init];
		[alert setMessageText:iTetUnsavedKeyboardConfigurationAlertTitle];
		[alert setInformativeText:iTetChangeWithUnsavedKeyboardConfigurationAlertInformativeText];
		[alert addButtonWithTitle:iTetSaveKeyboardConfigurationButtonTitle];
		[alert addButtonWithTitle:iTetCancelButtonTitle];
		[alert addButtonWithTitle:iTetChangeWithoutSavingKeyboardConfigurationButtonTitle];
		
		// Create a context info dictionary
		NSDictionary* infoDict = [NSDictionary dictionaryWithObject:sender
															 forKey:iTetOriginalSenderInfoKey];
		
		// Run the alert as a sheet
		[alert beginSheetModalForWindow:[[self view] window]
						  modalDelegate:self
						 didEndSelector:@selector(unsavedConfigAlertDidEnd:returnCode:contextInfo:)
							contextInfo:[infoDict retain]];
		
		return;
	}
	
	// Switch to the selected configuration
	[self displayConfigurationNumber:[sender tag]];
}

- (IBAction)saveConfiguration:(id)sender
{
	// Run the "save configuration" sheet
	[NSApp beginSheet:saveSheetWindow
	   modalForWindow:[[self view] window]
	    modalDelegate:self
	   didEndSelector:@selector(saveSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (IBAction)closeSaveSheet:(id)sender
{	
	[NSApp endSheet:saveSheetWindow
	     returnCode:[sender tag]];
}

#define iTetDeleteKeyboardConfigurationAlertTitle					NSLocalizedStringFromTable(@"Delete Keyboard Configuration", @"KeyboardPrefsViewController", @"Title of the alert displayed to confirm the deletion of a keyboard configuration")
#define iTetDeleteKeyboardConfigurationAlertInformativeTextFormat	NSLocalizedStringFromTable(@"Are you sure you want to delete the configuration '%@'?", @"KeyboardPrefsViewController", @"Informative text asking the user for confirmation to delete a specified keyboard configuration")

- (IBAction)deleteConfiguration:(id)sender
{
	// Get the current configuration name
	NSString* configName = [[iTetKeyConfiguration currentKeyConfiguration] configurationName];
	
	// Ask the user for confirmation via an alert
	NSAlert* alert = [[NSAlert alloc] init];
	[alert setMessageText:iTetDeleteKeyboardConfigurationAlertTitle];
	[alert setInformativeText:[NSString stringWithFormat:iTetDeleteKeyboardConfigurationAlertInformativeTextFormat, configName]];
	[alert addButtonWithTitle:iTetDeleteButtonTitle];
	[alert addButtonWithTitle:iTetCancelButtonTitle];
	
	// Run the alert as a sheet
	[alert beginSheetModalForWindow:[[self view] window]
					  modalDelegate:self
					 didEndSelector:@selector(deleteConfigAlertDidEnd:returnCode:contextInfo:)
						contextInfo:NULL];
}

#pragma mark -
#pragma mark View Swapping/Closing

#define iTetDismissWithUnsavedKeyboardConfigurationAlertInformativeText	NSLocalizedStringFromTable(@"Your current key configuration is unsaved. Do you wish to save the configuration?", @"KeyboardPrefsViewController", @"Informative text asking for confirmation before dismissing the keyboard configurations preference pane with an unsaved active configuration")

- (BOOL)viewShouldBeSwappedForView:(iTetPreferencesViewController*)newController
				byWindowController:(iTetPreferencesWindowController*)sender
{
	if (unsavedConfiguration != nil)
	{
		// Create an "unsaved configuration" alert
		NSAlert* alert = [[NSAlert alloc] init];
		[alert setMessageText:iTetUnsavedKeyboardConfigurationAlertTitle];
		[alert setInformativeText:iTetDismissWithUnsavedKeyboardConfigurationAlertInformativeText];
		[alert addButtonWithTitle:iTetSaveKeyboardConfigurationButtonTitle];
		[alert addButtonWithTitle:iTetCancelButtonTitle];
		[alert addButtonWithTitle:iTetDoNotSaveButtonTitle];
		
		// Create a context info dictionary
		NSDictionary* infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
								  sender, iTetOriginalSenderInfoKey,
								  newController, iTetNewControllerInfoKey,
								  nil];
		
		// Run the alert as a sheet
		[alert beginSheetModalForWindow:[[self view] window]
						  modalDelegate:self
						 didEndSelector:@selector(unsavedConfigAlertDidEnd:returnCode:contextInfo:)
							contextInfo:infoDict];
		
		return NO;
	}
	
	return YES;
}

- (BOOL)windowShouldClose:(id)window
{
	if (unsavedConfiguration != nil)
	{
		// Create an "unsaved configuration" alert
		NSAlert* alert = [[NSAlert alloc] init];
		[alert setMessageText:iTetUnsavedKeyboardConfigurationAlertTitle];
		[alert setInformativeText:iTetDismissWithUnsavedKeyboardConfigurationAlertInformativeText];
		[alert addButtonWithTitle:iTetSaveKeyboardConfigurationButtonTitle];
		[alert addButtonWithTitle:iTetCancelButtonTitle];
		[alert addButtonWithTitle:iTetDoNotSaveButtonTitle];
		
		// Create a context info dictionary
		NSDictionary* infoDict = [NSDictionary dictionaryWithObject:window
															 forKey:iTetWindowToCloseInfoKey];
		
		// Run the alert as a sheet
		[alert beginSheetModalForWindow:[[self view] window]
						  modalDelegate:self
						 didEndSelector:@selector(unsavedConfigAlertDidEnd:returnCode:contextInfo:)
							contextInfo:[infoDict retain]];
		
		return NO;
	}
	
	return YES;
}

- (void)viewWillBeRemoved:(id)sender
{
	// Un-highlight all key views
	for (iTetKeyView* keyView in keyViews)
		[keyView setHighlighted:NO];
}

- (void)viewWasSwappedIn:(id)sender
{
	// Display the active configuration
	[self displayConfigurationNumber:CURRENT_CONFIG_NUM];
}

#pragma mark -
#pragma mark Modal Dialog Callbacks

- (void)unsavedConfigAlertDidEnd:(NSAlert*)alert
					  returnCode:(NSInteger)returnCode
					 contextInfo:(NSDictionary*)infoDict
{	
	// We're done with the sheet; ask it to order out
	[[alert window] orderOut:self];
	
	// Balance the allocation of the context-info dictionary
	[infoDict autorelease];
	
	// If the user pressed "cancel", re-select the unsaved config in the pop-up menu
	if (returnCode == NSAlertSecondButtonReturn)
	{
		[configurationPopUpButton selectItemWithTitle:iTetUnsavedKeyboardConfigurationPlaceholderName];
		return;
	}
	
	// If the user pressed "don't save", delete the configuration
	if (returnCode == NSAlertThirdButtonReturn)
	{
		[self clearUnsavedConfiguration];
		
		// Determine what to do next
		
		// If the context info has a "new view controller" object, we need to swap this view out
		iTetPreferencesViewController* newController = [infoDict objectForKey:iTetNewControllerInfoKey];
		if (newController != nil)
		{
			// Get the window controller out of the context info dictionary
			iTetPreferencesWindowController* windowController = [infoDict objectForKey:iTetOriginalSenderInfoKey];
			
			// Call the window controller back, ask it to switch views
			[windowController displayViewController:newController];
			
			return;
		}
		
		// If the context info has a "window to close" object, tell it to close
		NSWindow* window = [infoDict objectForKey:iTetWindowToCloseInfoKey];
		if (window != nil)
		{
			// Close the window
			[window close];
			
			return;
		}
		
		[self displayConfigurationNumber:[[infoDict objectForKey:iTetOriginalSenderInfoKey] tag]];
		
		return;
	}
	
	// Otherwise, open the "save configuration" sheet
	[self saveConfiguration:self];
}

#define iTetReplaceKeyboardConfigurationAlertTitle				NSLocalizedStringFromTable(@"Replace Keyboard Configuration", @"KeyboardPrefsViewController", @"Title of the alert displayed when the user attempts to save a keyboard configuration using the name of an existing configuration")
#define iTetReplaceKeyboardConfigurationAlertInformativeText	NSLocalizedStringFromTable(@"A keyboard configuration already exists with the name '%@'. Would you like to replace it?", @"KeyboardPrefsViewController", @"Informative text asking the user whether he or she would like to overwrite an existing keyboard configuration of the same name, or cancel saving")

- (void)saveSheetDidEnd:(NSWindow*)sheet
			 returnCode:(NSInteger)returnCode
			contextInfo:(void*)context
{
	// If the user pressed "cancel", do nothing
	if (returnCode == 0)
	{
		[sheet orderOut:self];
		
		// Re-select the configuration in the pop-up menu
		[configurationPopUpButton selectItemWithTitle:[unsavedConfiguration configurationName]];
		
		return;
	}
	
	// If the user pressed "save", attempt to save the configuration
	// Get the name from the text field
	NSString* newConfigName = [configurationNameField stringValue];
	
	// Check for duplicate configuration name
	NSArray* configs = KEY_CONFIGS;
	iTetKeyConfiguration* config;
	for (NSUInteger i = 0; i < [configs count]; i++)
	{
		config = [configs objectAtIndex:i];
		
		if ([[config configurationName] isEqualToString:newConfigName])
		{	
			// Create a new alert
			NSAlert* alert = [[NSAlert alloc] init];
			[alert setMessageText:iTetReplaceKeyboardConfigurationAlertTitle];
			[alert setInformativeText:[NSString stringWithFormat:iTetReplaceKeyboardConfigurationAlertInformativeText, newConfigName]];
			[alert addButtonWithTitle:iTetReplaceButtonTitle];
			[alert addButtonWithTitle:iTetCancelButtonTitle];
			
			// Order out the old sheet
			[sheet orderOut:self];
			
			// Run the new alert
			[alert beginSheetModalForWindow:[[self view] window]
							  modalDelegate:self
							 didEndSelector:@selector(duplicateConfigAlertEnded:returnCode:indexToReplace:)
								contextInfo:[[NSNumber numberWithUnsignedInteger:i] retain]];
			return;
		}
	}
	
	// Make a copy of the unsaved configuration
	iTetKeyConfiguration* newConfig = [[unsavedConfiguration copy] autorelease];
	
	// Set the configuration name
	[newConfig setConfigurationName:newConfigName];
	
	// Clear the unsaved configuration
	[self clearUnsavedConfiguration];
	
	// Add the new configuration to the list
	NSArray* newConfigs = [configs arrayByAddingObject:newConfig];
	[[NSUserDefaults standardUserDefaults] archiveAndSetObject:newConfigs
														forKey:iTetKeyConfigsListPrefKey];
	
	// Get the index of the new configuration
	NSUInteger index = [newConfigs indexOfObject:newConfig];
	
	// Add the new configuration name to the pop-up menu
	[self insertConfiguration:newConfig
		   inPopUpMenuAtIndex:index
					tagNumber:index];
	
	// Select the configuration
	[self displayConfigurationNumber:index];
	
	// Order out the sheet
	[sheet orderOut:self];
}

- (void)duplicateConfigAlertEnded:(NSAlert*)alert
					   returnCode:(NSInteger)returnCode
				   indexToReplace:(NSNumber*)indexToReplace
{
	// Balance retain
	[indexToReplace autorelease];
	
	// If the user pressed "cancel", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
	{
		// Re-select the unsaved configuration in the pop-up menu
		[configurationPopUpButton selectItemWithTitle:[unsavedConfiguration configurationName]];
		
		return;
	}
	
	// If the user pressed "replace", replace the existing configuration
	// Get the index of the configuration to replace
	NSUInteger index = [indexToReplace unsignedIntegerValue];
	
	// Set the configuration name (same as the config we are replacing)
	NSMutableArray* configs = [NSMutableArray arrayWithArray:KEY_CONFIGS];
	[unsavedConfiguration setConfigurationName:[[configs objectAtIndex:index] configurationName]];
	
	// Replace the old configuration with the new
	[configs replaceObjectAtIndex:index
					   withObject:unsavedConfiguration];
	[[NSUserDefaults standardUserDefaults] archiveAndSetObject:configs
														forKey:iTetKeyConfigsListPrefKey];
	
	// Clear the unsaved configuration
	[self clearUnsavedConfiguration];
	
	// Do not add the configuration name to the pop-up button, should already be present
	
	// Select the configuration
	[self displayConfigurationNumber:index];
}

- (void)deleteConfigAlertDidEnd:(NSAlert*)alert
					 returnCode:(NSInteger)returnCode
					contextInfo:(void*)context
{
	NSUInteger configNum = CURRENT_CONFIG_NUM;
	NSMenu* menu = [configurationPopUpButton menu];
	
	// If the user pressed "cancel", do not delete
	if (returnCode == NSAlertSecondButtonReturn)
	{
		// De-select the "delete configuration" item in the pop-up menu
		[configurationPopUpButton selectItemWithTag:configNum];
		
		return;
	}
	
	// Delete the currently selected configuration from the list of configurations
	NSMutableArray* configs = [NSMutableArray arrayWithArray:KEY_CONFIGS];
	[configs removeObjectAtIndex:configNum];
	[[NSUserDefaults standardUserDefaults] archiveAndSetObject:configs
														forKey:iTetKeyConfigsListPrefKey];
	
	// Remove the configuration name from the pop-up menu
	[menu removeItem:[menu itemWithTag:configNum]];
	
	// Select the first configuration in the list
	[self displayConfigurationNumber:0];
}

#pragma mark -
#pragma mark Configurations

- (void)insertConfiguration:(iTetKeyConfiguration*)config
		 inPopUpMenuAtIndex:(NSUInteger)index
				  tagNumber:(NSUInteger)tag
{
	// Create a menu item
	NSMenuItem* item = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[config configurationName]
																			 action:@selector(changeConfiguration:)
																	  keyEquivalent:@""] autorelease];
	[item setTarget:self];
	[item setTag:tag];
	
	// Add it to the menu
	[[configurationPopUpButton menu] insertItem:item
										atIndex:index];
}

- (void)displayConfigurationNumber:(NSUInteger)configNum
{
	// Set the new active configuration
	[[NSUserDefaults standardUserDefaults] setUnsignedInteger:configNum 
													   forKey:iTetCurrentKeyConfigNumberPrefKey];
	
	// Set the active keys in the key views
	iTetKeyConfiguration* configToDisplay = [KEY_CONFIGS objectAtIndex:configNum];
	for (iTetKeyView* keyView in keyViews)
		[keyView setRepresentedKey:[configToDisplay keyBindingForAction:[keyView associatedAction]]];
	
	// Select the configuration in the pop-up menu
	[configurationPopUpButton selectItemWithTag:configNum];
}

- (void)clearUnsavedConfiguration
{
	// Remove the unsaved configuration from the pop-up menu
	NSMenu* menu = [configurationPopUpButton menu];
	[menu removeItem:[menu itemWithTitle:iTetUnsavedKeyboardConfigurationPlaceholderName]];
	
	// Delete the configuration
	[unsavedConfiguration release];
	unsavedConfiguration = nil;
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
	// If this isn't a key view, we don't care (and we shouldn't be getting this notification...)
	if (![object isKindOfClass:[iTetKeyView class]])
		return;
	
	// Cast to a key view
	iTetKeyView* keyView = (iTetKeyView*)object;
	
	// Determine whether the view is highlighted
	if ([[changeDict objectForKey:NSKeyValueChangeNewKey] boolValue])
	{
		// Key view is now highlighted: set the description text to that key view's description
		[self setKeyDescriptionForKeyView:keyView];
	}
	else
	{
		// Key view is no longer highlighted: if the description text currently contains a message prompting the user to press a key, clear the text
		if (displayingPrompt)
		{
			[keyDescriptionField setStringValue:[NSString string]];
			displayingPrompt = NO;
		}
	}
}

#pragma mark -
#pragma mark iTetKeyView Delegate Methods

#define iTetKeyAlreadyBoundMessage	NSLocalizedStringFromTable(@"'%@' is already bound to '%@'", @"KeyboardPrefsViewController", @"Message displayed on the keyboard preferences pane when a user attempts to bind a key that is already bound to another action")

- (BOOL)keyView:(iTetKeyView*)keyView
shouldSetRepresentedKey:(iTetKeyNamePair*)key
{
	// Check if the pressed key is already in use
	iTetGameAction boundAction;
	if (unsavedConfiguration != nil)
	{
		boundAction = [unsavedConfiguration actionForKeyBinding:key];
	}
	else
	{
		boundAction = [[iTetKeyConfiguration currentKeyConfiguration] actionForKeyBinding:key];
	}
	
	// If the action is already bound, disallow the binding
	if (boundAction != noAction)
	{
		// If the key is bound to another action, inform the user
		if (boundAction != [keyView associatedAction])
		{
			NSBeep();
			
			// Place a warning in the text field
			[keyDescriptionField setStringValue:[NSString stringWithFormat:iTetKeyAlreadyBoundMessage, [key printedName], iTetNameForAction(boundAction)]];
			displayingPrompt = NO;
		}
		
		return NO;
	}
	
	return YES;
}

- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(iTetKeyNamePair*)key
{	
	// If the current configuration is clean, make a copy
	if (unsavedConfiguration == nil)
	{
		// Copy the current configuration
		unsavedConfiguration = [[iTetKeyConfiguration currentKeyConfiguration] copy];
		
		// Change the copy's name
		[unsavedConfiguration setConfigurationName:iTetUnsavedKeyboardConfigurationPlaceholderName];
		
		// Add the configuration to the pop-up menu
		NSUInteger newConfigNum = [KEY_CONFIGS count];
		[self insertConfiguration:unsavedConfiguration
			   inPopUpMenuAtIndex:newConfigNum
						tagNumber:newConfigNum];
		
		// Select the item in the menu
		[configurationPopUpButton selectItemAtIndex:newConfigNum];
	}
	
	// Change the key in the unsaved configuration
	[unsavedConfiguration setAction:[keyView associatedAction]
					  forKeyBinding:key];
	
	// Clear the text field
	[keyDescriptionField setStringValue:[NSString string]];
	displayingPrompt = NO;
}

#pragma mark -
#pragma mark Interface Item Validation

- (void)controlTextDidChange:(NSNotification*)note
{	
	if ([[[note userInfo] objectForKey:@"NSFieldEditor"] isEqual:[configurationNameField currentEditor]])
		[saveButton setEnabled:([[configurationNameField stringValue] length] > 0)];
}

- (BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
	if ([menuItem action] == @selector(saveConfiguration:))
	{
		if (unsavedConfiguration != nil)
			return YES;
		
		return NO;
	}
	
	if ([menuItem action] == @selector(deleteConfiguration:))
	{
		if (unsavedConfiguration != nil)
			return NO;
		
		if ([KEY_CONFIGS count] <= 1)
			return NO;
		
		return YES;
	}
	
	return YES;
}

#pragma mark -
#pragma mark Accessors

- (void)setKeyDescriptionForKeyView:(iTetKeyView*)keyView
{
	[keyDescriptionField setStringValue:[NSString stringWithFormat:iTetKeyDescriptionFormat, iTetNameForAction([keyView associatedAction])]];
	displayingPrompt = YES;
}

@end
