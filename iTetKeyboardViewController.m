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
	// Set the actions associated with the key views
	[moveLeftKeyView setAssociatedAction:movePieceLeft];
	[moveRightKeyView setAssociatedAction:movePieceRight];
	[rotateCounterclockwiseKeyView setAssociatedAction:rotatePieceCounterclockwise];
	[rotateClockwiseKeyView setAssociatedAction:rotatePieceClockwise];
	[moveDownKeyView setAssociatedAction:movePieceDown];
	[dropKeyView setAssociatedAction:dropPiece];
	[gameChatKeyView setAssociatedAction:gameChat];
	
	// Fill the pop-up menu with the available keyboard configurations
	NSArray* configurations = [[self preferencesController] keyConfigurations];
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
	
	// Bind the save button availa
	
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
	// We're done with the sheet; ask it to order out
	[[alert window] orderOut:self];
	
	// If the user pressed "cancel", re-select the unsaved config in the pop-up menu
	if (returnCode == NSAlertSecondButtonReturn)
	{
		[configurationPopUpButton selectItemWithTitle:[unsavedConfiguration configurationName]];
		return;
	}
		
	
	// If the user pressed "change without saving", discard changes and change configurations
	if (returnCode == NSAlertThirdButtonReturn)
	{
		[self clearUnsavedConfiguration];
		[self displayConfigurationNumber:[sender tag]];
		return;
	}
	
	// Otherwise, open the "save configuration" sheet
	[self saveConfiguration:self];
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
	NSArray* configs = [[self preferencesController] keyConfigurations];
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
	[[self preferencesController] addKeyConfiguration:newConfig];
	
	// Get the index of the new configuration
	NSUInteger i = [[[self preferencesController] keyConfigurations] count] - 1;
	
	// Add the new configuration name to the pop-up menu
	[self insertConfiguration:newConfig
		 inPopUpMenuAtIndex:i
			    tagNumber:i];
	
	// Select the configuration
	[self displayConfigurationNumber:i];
	[configurationPopUpButton selectItemAtIndex:i];
	
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
	 [[[[self preferencesController] keyConfigurations] objectAtIndex:i] configurationName]];
	
	// Clear the unsaved configuration
	[self clearUnsavedConfiguration];
	
	// Replace the configuration
	[[self preferencesController] replaceKeyConfigurationAtIndex:i
							    withKeyConfiguration:newConfig];
	
	// Do not add the configuration name to the pop-up button, should already be present
	
	// Select the configuration
	[self displayConfigurationNumber:i];
	[configurationPopUpButton selectItemAtIndex:i];
}

- (IBAction)deleteConfiguration:(id)sender
{
	// Get the current configuration name
	NSString* configName = [[[self preferencesController] currentKeyConfiguration] configurationName];
	
	// Ask the user for confirmation via an alert
	NSAlert* alert = [[NSAlert alloc] init];
	[alert setMessageText:@"Delete Configuration?"];
	[alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete the configuration named \"%@\"?", configName]];
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	
	// Run the alert as a sheet
	[alert beginSheetModalForWindow:[[self view] window]
				modalDelegate:self
			     didEndSelector:@selector(deleteConfigAlertDidEnd:returnCode:contextInfo:)
				  contextInfo:NULL];
}

- (void)deleteConfigAlertDidEnd:(NSAlert*)alert
			   returnCode:(NSInteger)returnCode
			  contextInfo:(void*)context
{
	NSUInteger configNum = [[self preferencesController] currentKeyConfigurationNumber];
	NSMenu* menu = [configurationPopUpButton menu];
	
	// If the user pressed "cancel", do not delete
	if (returnCode == NSAlertSecondButtonReturn)
	{
		// Select the current config in the pop-up menu
		[configurationPopUpButton selectItem:[menu itemWithTag:configNum]];
		
		return;
	}
	
	// Delete the currently selected configuration from the list of configurations
	[[self preferencesController] removeKeyConfigurationAtIndex:configNum];
	
	// Remove the configuration name from the pop-up menu
	[menu removeItem:[menu itemWithTag:configNum]];
	
	// Select the first configuration in the list
	[configurationPopUpButton selectItem:[menu itemWithTag:0]];
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
		NSMutableDictionary* currentConfig = [[self preferencesController] currentKeyConfiguration];
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
		unsavedConfiguration = [[[self preferencesController] currentKeyConfiguration] mutableCopy];
		
		// Change the copy's name
		[unsavedConfiguration setConfigurationName:@"Custom"];
		
		// Add the configuration to the pop-up menu
		NSUInteger newConfigNum = [[[self preferencesController] keyConfigurations] count];
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
		
		if ([[[self preferencesController] keyConfigurations] count] <= 1)
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

- (iTetPreferencesController*)preferencesController
{
	return [iTetPreferencesController preferencesController];
}

- (NSMutableDictionary*)keyConfigNumber:(NSUInteger)configNum
{	
	return [[[self preferencesController] keyConfigurations] objectAtIndex:configNum];
}

@end
