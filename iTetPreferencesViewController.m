//
//  iTetPreferencesViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/23/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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
