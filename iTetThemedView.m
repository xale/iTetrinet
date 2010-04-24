//
//  iTetThemedView.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/13/09.
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
															  forKeyPath:[@"values." stringByAppendingString:iTetCurrentThemeNumberPrefKey]
																 options:0
																 context:NULL];
	
	return self;
}

- (void)dealloc
{
	// De-register for notifications
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
																 forKeyPath:[@"values." stringByAppendingString:iTetCurrentThemeNumberPrefKey]];
	
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
	// Themed views, by default, do not accept key input; the one exception is the local player's board, implemented in iTetLocalBoardView
	return NO;
}

- (void)setTheme:(iTetTheme*)newTheme
{
	[newTheme retain];
	[theme release];
	theme = newTheme;
	
	[self setNeedsDisplay:YES];
}
@synthesize theme;

@end
