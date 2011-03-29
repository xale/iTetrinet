//
//  iTetPreferencesViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/23/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
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
	if (!(self = [super init]))
		return nil;
	
	if ([self isMemberOfClass:[iTetPreferencesViewController class]])
	{
		[self doesNotRecognizeSelector:_cmd];
		[self release];
		return nil;
	}
	
	return self;
}

#pragma mark -
#pragma mark Delegation Methods

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{
	// Subclasses can override for graceful-termination behavior
	return NSTerminateNow;
}

- (BOOL)windowShouldClose:(id)window
{
	// Subclasses can override for graceful-termination behavior
	return YES;
}

- (BOOL)viewShouldBeSwappedForView:(iTetPreferencesViewController*)newController
				byWindowController:(iTetPreferencesWindowController*)sender;
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
