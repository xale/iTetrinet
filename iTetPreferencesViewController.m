//
//  iTetPreferencesViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/23/09.
//

#import "iTetPreferencesViewController.h"

@implementation iTetPreferencesViewController

+ (id)viewController
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

#pragma mark -
#pragma mark Accessors

- (BOOL)viewShouldBeSwappedForView:(iTetPreferencesViewController*)newController
				byWindowController:(iTetPreferencesWindowController*)sender;
{
	// Subclasses can override for graceful-termination behavior
	return YES;
}

- (BOOL)windowShouldClose:(id)window
{
	// Subclasses can override for graceful-termination behavior
	return YES;
}

- (void)viewWillBeRemoved:(id)sender
{
	// By default, does nothing (subclasses override)
}

- (void)viewWasSwappedIn:(id)sender
{
	// By default, does nothing (subclasses override)
}

@end
