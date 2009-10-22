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
	
	currentViewNumber = -1;
	
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
	// Change to the specified view
	[self displayViewControllerAtIndex:[sender tag]];
}

- (void)displayViewControllerAtIndex:(iTetPreferencesTabNumber)index
{
	// Check if we are already displaying the view
	if (currentViewNumber == index)
		return;
	
	// Sanity check
	NSParameterAssert((index >= 0) && (index < [viewControllers count]));
	
	// Get the view swap in
	NSViewController* controller = [viewControllers objectAtIndex:index];
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
	
	// Set the window title to the title of the view controller
	[[self window] setTitle:[controller title]];
	
	// Resize the window
	[[self window] setFrame:windowFrame
			    display:YES
			    animate:YES];
	
	// Swap the view into the box
	[viewBox setContentView:view];
	
	[[self window] makeFirstResponder:view];
	
	// Record which view is being displayed
	currentViewNumber = index;
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
