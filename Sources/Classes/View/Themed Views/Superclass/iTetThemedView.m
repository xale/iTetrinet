//
//  iTetThemedView.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/13/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetThemedView.h"
#import "iTetUserDefaults.h"

@implementation iTetThemedView

- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	// Set the initial theme from user defaults
	theme = [[iTetTheme currentTheme] retain];
	
	// Register as an observer for changes to the theme
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
															  forKeyPath:[@"values." stringByAppendingString:iTetThemesSelectionPrefKey]
																 options:0
																 context:NULL];
	
	return self;
}

- (void)dealloc
{
	// De-register for notifications
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
																 forKeyPath:[@"values." stringByAppendingString:iTetThemesSelectionPrefKey]];
	
	// Release the theme
	[theme release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Theme Change Key/Value Observation

- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
						change:(NSDictionary*)change
					   context:(void *)context
{
	// Change to themes list; update the current theme
	[self setTheme:[iTetTheme currentTheme]];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)acceptsFirstResponder
{
	// Themed views, by default, do not accept key input; the one exception is the local player's field, implemented in iTetLocalFieldView
	return NO;
}

- (void)setTheme:(iTetTheme*)newTheme
{
	// Retain / Release / Replace
	[newTheme retain]
	[theme release];
	theme = newTheme;
	
	// Repaint
	[self setNeedsDisplay:YES];
}
@synthesize theme;

@end
