//
//  iTetPreferencesWindowController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetPreferencesWindowController.h"
#import "iTetGeneralPrefsViewController.h"
#import "iTetThemesViewController.h"
#import "iTetServersViewController.h"
#import "iTetKeyboardViewController.h"

@implementation iTetPreferencesWindowController

- (id)init
{
	if (![super initWithWindowNibName:@"PreferencesWindow"])
		return nil;
	
	// Create the view controllers
	viewControllers = [[NSArray alloc] initWithObjects:
					   [iTetGeneralPrefsViewController viewController],
					   [iTetThemesViewController viewController],
					   [iTetServersViewController viewController],
					   [iTetKeyboardViewController viewController],
					   nil];
	
	currentViewNumber = noPreferencesTab;
	
	return self;
}

- (void)awakeFromNib
{
	// Display the "general" tab
	[self displayViewControllerAtIndex:generalPreferencesTab];
}

- (void)dealloc
{
	[viewControllers release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark View Switching

- (IBAction)changeView:(id)sender
{
	[self displayViewControllerAtIndex:[sender tag]];
}

- (void)displayViewControllerAtIndex:(iTetPreferencesTabNumber)index
{
	// Sanity check
	NSParameterAssert((index >= 0) && (((NSUInteger)index) < [viewControllers count]));
	
	// Check if we are already displaying the view
	if (currentViewNumber == index)
		return;
	
	// Get the controller to swap in
	iTetPreferencesViewController* newController = [viewControllers objectAtIndex:index];
	
	// If we are swapping out a controller, confirm it is safe to do so
	if (currentViewNumber != noPreferencesTab)
	{
		// Get the current controller
		iTetPreferencesViewController* controller = [viewControllers objectAtIndex:currentViewNumber];
		
		// Ask the current view controller if it is okay to swap
		if (![controller viewShouldBeSwappedForView:newController
								 byWindowController:self])
			return;
	}
	
	// Change to the specified view
	[self displayViewController:newController];
}

- (void)displayViewController:(iTetPreferencesViewController*)controller
{
	// If we are swapping out a view controller, inform it
	if (currentViewNumber != noPreferencesTab)
		[[viewControllers objectAtIndex:currentViewNumber] viewWillBeRemoved:self];
	
	// Get the view swap in
	NSView* view = [controller view];
	
	// Compute the new window size
	NSSize currentSize = [[viewBox contentView] frame].size;
	NSSize newSize = [view frame].size;
	CGFloat deltaWidth = newSize.width - currentSize.width;
	CGFloat deltaHeight = newSize.height - currentSize.height;
	NSRect windowFrame = [[self window] frame];
	windowFrame.size.width += deltaWidth;
	windowFrame.size.height += deltaHeight;
	windowFrame.origin.y -= deltaHeight;
	
	// Clear the window for resizing
	[viewBox setContentView:nil];
	
	// Resize the window
	[[self window] setFrame:windowFrame
					display:YES
					animate:YES];
	
	// Swap the view into the box
	[viewBox setContentView:view];
	
	// Set the window title to the title of the view controller
	[[self window] setTitle:[controller title]];
	
	// Make the view first responder
	[[self window] makeFirstResponder:view];
	
	// Inform the view controller it has been swapped in
	[controller viewWasSwappedIn:self];
	
	// Record the number of the view being displayed
	currentViewNumber = [viewControllers indexOfObject:controller];
}

#pragma mark -
#pragma mark NSWindow Delegate Methods

- (BOOL)windowShouldClose:(id)window
{
	// Ask the current view controller if it is okay to close
	return [[viewControllers objectAtIndex:currentViewNumber] windowShouldClose:window];
}

#pragma mark -
#pragma mark NSToolbar Delegate Methods

- (NSArray*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects: [general itemIdentifier],
			[themes itemIdentifier], [servers itemIdentifier],
			[keyboard itemIdentifier], nil];
}

@end
