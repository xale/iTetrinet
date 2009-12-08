//
//  iTetKeyboardViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetKeyboardViewController.h"
#import "iTetKeyView.h"
#import "iTetKeyNamePair.h"
#import "NSMutableDictionary+KeyBindings.h"

NSString* const iTetOriginalSenderInfoKey =	@"originalSender";
NSString* const iTetNewControllerInfoKey =	@"newController";
NSString* const iTetWindowToCloseInfoKey =	@"windowToClose";

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
	// Set the actions associated with the key views
	[moveLeftKeyView setAssociatedAction:movePieceLeft];
	[moveRightKeyView setAssociatedAction:movePieceRight];
	[rotateCounterclockwiseKeyView setAssociatedAction:rotatePieceCounterclockwise];
	[rotateClockwiseKeyView setAssociatedAction:rotatePieceClockwise];
	[moveDownKeyView setAssociatedAction:movePieceDown];
	[dropKeyView setAssociatedAction:dropPiece];
	[discardSpecialKeyView setAssociatedAction:discardSpecial];
	[gameChatKeyView setAssociatedAction:gameChat];
	
	// Add the key views to an array for easy enumeration
	keyViews = [[NSArray alloc] initWithObjects:
			moveLeftKeyView,
			moveRightKeyView,
			rotateCounterclockwiseKeyView,
			rotateClockwiseKeyView,
			moveDownKeyView,
			dropKeyView,
			discardSpecialKeyView,
			gameChatKeyView, nil];
	
	// Register for notifications when a key view changes highlight state
	for (iTetKeyView* keyView in keyViews)
		[self startObservingKeyView:keyView];
	
	// Fill the pop-up menu with the available keyboard configurations
	NSArray* configurations = [PREFS keyConfigurations];
	int numConfigs = [configurations count];
	for (int i = 0; i < numConfigs; i++)
	{
		[self insertConfiguration:[configurations objectAtIndex:i]
			 inPopUpMenuAtIndex:i
				    tagNumber:i];
	}
	
	// Add a separator menu item to the pop-up menu
	[[configurationPopUpButton menu] addItem:[NSMenuItem separatorItem]];
	
	// Add the "save configuration" menu item
	NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:@"Save Configuration..."
									  action:@selector(saveConfiguration:)
								 keyEquivalent:@""];
	[menuItem setTarget:self];
	[[configurationPopUpButton menu] addItem:menuItem];
	[menuItem release];
	
	// Add the "delete configuration" menu item
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Delete Configuration"
							  action:@selector(deleteConfiguration:)
						 keyEquivalent:@""];
	[menuItem setTarget:self];
	[[configurationPopUpButton menu] addItem:menuItem];
	[menuItem release];
	
	// Display the active configuration in the key views
	NSUInteger currentConfigNum = [PREFS currentKeyConfigurationNumber];
	[self displayConfigurationNumber:currentConfigNum];
	
	// Clear the description text
	[keyDescriptionField setStringValue:@""];
}

- (void)dealloc
{
	// If we have an unsaved configuration, release it
	[unsavedConfiguration release];
	
	// Stop observing key view highlight states
	for (iTetKeyView* keyView in keyViews)
		[self stopObservingKeyView:keyView];
	
	// Release the array of key views
	[keyViews release];
	
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

- (IBAction)deleteConfiguration:(id)sender
{
	// Get the current configuration name
	NSString* configName = [[PREFS currentKeyConfiguration] configurationName];
	
	// Ask the user for confirmation via an alert
	NSAlert* alert = [[NSAlert alloc] init];
	[alert setMessageText:@"Delete Configuration"];
	[alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete the configuration named \"%@\"?", configName]];
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	
	// Run the alert as a sheet
	[alert beginSheetModalForWindow:[[self view] window]
				modalDelegate:self
			     didEndSelector:@selector(deleteConfigAlertDidEnd:returnCode:contextInfo:)
				  contextInfo:NULL];
}

#pragma mark -
#pragma mark View Swapping/Closing

- (BOOL)viewShouldBeSwappedForView:(iTetPreferencesViewController*)newController
		    byWindowController:(iTetPreferencesWindowController*)sender
{
	if (unsavedConfiguration)
	{
		// Create an "unsaved configuration" alert
		NSAlert* alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Unsaved Configuration"];
		[alert setInformativeText:@"Your current key configuration is unsaved. Do you  wish to save the configuration?"];
		[alert addButtonWithTitle:@"Save Configuration"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert addButtonWithTitle:@"Don't Save"];
		
		// Create a context info dictionary
		NSDictionary* infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  sender, iTetOriginalSenderInfoKey,
						  newController, iTetNewControllerInfoKey, nil];
		
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
	if (unsavedConfiguration)
	{
		// Create an "unsaved configuration" alert
		NSAlert* alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Unsaved Configuration"];
		[alert setInformativeText:@"Your current key configuration is unsaved. Do you  wish to save the configuration?"];
		[alert addButtonWithTitle:@"Save Configuration"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert addButtonWithTitle:@"Don't Save"];
		
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
	[self displayConfigurationNumber:[PREFS currentKeyConfigurationNumber]];
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
		[configurationPopUpButton selectItemWithTitle:[unsavedConfiguration configurationName]];
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
		
		// If the context info has a "window to close" object, send it a 
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
	NSArray* configs = [PREFS keyConfigurations];
	NSMutableDictionary* config;
	NSUInteger numConfigs = [configs count];
	for (NSUInteger i = 0; i < numConfigs; i++)
	{
		config = [configs objectAtIndex:i];
		
		if ([[config configurationName] isEqualToString:newConfigName])
		{	
			// Create a new alert
			NSAlert* alert = [[NSAlert alloc] init];
			[alert setMessageText:@"Duplicate Configuration"];
			[alert setInformativeText:[NSString stringWithFormat:@"A keyboard configuration already exists with the name \"%@\". Would you like to replace it?", newConfigName]];
			[alert addButtonWithTitle:@"Replace"];
			[alert addButtonWithTitle:@"Cancel"];
			
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
	NSMutableDictionary* newConfig = [unsavedConfiguration mutableCopy];
	
	// Set the configuration name
	[newConfig setConfigurationName:newConfigName];
	
	// Clear the unsaved configuration
	[self clearUnsavedConfiguration];
	
	// Add the new configuration to the list
	[PREFS addKeyConfiguration:newConfig];
	
	// Get the index of the new configuration
	NSUInteger i = [[PREFS keyConfigurations] count] - 1;
	
	// Add the new configuration name to the pop-up menu
	[self insertConfiguration:newConfig
		 inPopUpMenuAtIndex:i
			    tagNumber:i];
	
	// Select the configuration
	[self displayConfigurationNumber:i];
	
	// Order out the sheet
	[sheet orderOut:self];
}

- (void)duplicateConfigAlertEnded:(NSAlert*)alert
			     returnCode:(NSInteger)returnCode
			 indexToReplace:(NSNumber*)index
{
	// Balance retain
	[index autorelease];
	
	// If the user pressed "cancel", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
	{
		// Re-select the unsaved configuration in the pop-up menu
		[configurationPopUpButton selectItemWithTitle:[unsavedConfiguration configurationName]];
		
		return;
	}
	
	// If the user pressed "replace", replace the existing configuration
	// Get the index of the configuration to replace
	NSUInteger i = [index unsignedIntValue];
	
	// Make a copy of the unsaved configuration
	NSMutableDictionary* newConfig = [unsavedConfiguration mutableCopy];
	
	// Set the configuration name (same as the config we are replacing)
	[newConfig setConfigurationName:
	 [[[PREFS keyConfigurations] objectAtIndex:i] configurationName]];
	
	// Clear the unsaved configuration
	[self clearUnsavedConfiguration];
	
	// Replace the configuration
	[PREFS replaceKeyConfigurationAtIndex:i
			     withKeyConfiguration:newConfig];
	
	// Do not add the configuration name to the pop-up button, should already be present
	
	// Select the configuration
	[self displayConfigurationNumber:i];
}

- (void)deleteConfigAlertDidEnd:(NSAlert*)alert
			   returnCode:(NSInteger)returnCode
			  contextInfo:(void*)context
{
	NSUInteger configNum = [PREFS currentKeyConfigurationNumber];
	NSMenu* menu = [configurationPopUpButton menu];
	
	// If the user pressed "cancel", do not delete
	if (returnCode == NSAlertSecondButtonReturn)
	{
		// Select the current config in the pop-up menu
		[configurationPopUpButton selectItemWithTag:configNum];
		
		return;
	}
	
	// Delete the currently selected configuration from the list of configurations
	[PREFS removeKeyConfigurationAtIndex:configNum];
	
	// Remove the configuration name from the pop-up menu
	[menu removeItem:[menu itemWithTag:configNum]];
	
	// Select the first configuration in the list
	[self displayConfigurationNumber:0];
}

#pragma mark -
#pragma mark Configurations

- (void)insertConfiguration:(NSMutableDictionary*)config
	   inPopUpMenuAtIndex:(NSUInteger)index
			tagNumber:(NSUInteger)tag
{
	// Create a menu item
	NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:[config configurationName]
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
	[PREFS setCurrentKeyConfigurationNumber:configNum];
	
	// Set the active keys in the key views
	NSMutableDictionary* currentConfig = [self keyConfigNumber:configNum];
	for (iTetKeyView* keyView in keyViews)
		[keyView setRepresentedKey:[currentConfig keyForAction:[keyView associatedAction]]];
	
	// Select the configuration in the pop-up menu
	[configurationPopUpButton selectItemWithTag:configNum];
}

- (void)clearUnsavedConfiguration
{
	// Remove the unsaved configuration from the pop-up menu
	NSMenu* menu = [configurationPopUpButton menu];
	[menu removeItem:[menu itemWithTitle:[unsavedConfiguration configurationName]]];
	
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
	iTetGameAction boundAction;
	if (unsavedConfiguration)
	{
		boundAction = [unsavedConfiguration actionForKey:key];
	}
	else
	{
		NSMutableDictionary* currentConfig = [PREFS currentKeyConfiguration];
		boundAction = [currentConfig actionForKey:key];
	}
	
	if (boundAction != noAction)
	{
		if (boundAction != [keyView associatedAction])
		{
			// Place a warning in the text field
			[keyDescriptionField setStringValue:
			 [NSString stringWithFormat:@"\'%@\' is already bound to \"%@\"",
			  [key printedName], iTetNameForAction(boundAction)]];
			
			NSBeep();
		}
		
		return NO;
	}
	
	return YES;
}

- (void)keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(iTetKeyNamePair*)key
{	
	// If the current configuration is clean, make a copy
	if (!unsavedConfiguration)
	{
		// Copy the current configuration
		unsavedConfiguration = [[PREFS currentKeyConfiguration] mutableCopy];
		
		// Change the copy's name
		[unsavedConfiguration setConfigurationName:@"Custom"];
		
		// Add the configuration to the pop-up menu
		NSUInteger newConfigNum = [[PREFS keyConfigurations] count];
		[self insertConfiguration:unsavedConfiguration
			 inPopUpMenuAtIndex:newConfigNum
				    tagNumber:newConfigNum];
		
		// Select the item in the menu
		[configurationPopUpButton selectItemAtIndex:newConfigNum];
	}
	
	// Change the key in the unsaved configuration
	[unsavedConfiguration setAction:[keyView associatedAction]
					 forKey:key];
	
	// Clear the text field
	[keyDescriptionField setStringValue:@""];
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
		if (unsavedConfiguration)
			return YES;
		
		return NO;
	}
	
	if ([menuItem action] == @selector(deleteConfiguration:))
	{
		if (unsavedConfiguration)
			return NO;
		
		if ([[PREFS keyConfigurations] count] <= 1)
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
	 [NSString stringWithFormat:iTetKeyDescriptionFormat,
	  iTetNameForAction([keyView associatedAction])]];
}

- (NSMutableDictionary*)keyConfigNumber:(NSUInteger)configNum
{	
	return [[PREFS keyConfigurations] objectAtIndex:configNum];
}

@end
