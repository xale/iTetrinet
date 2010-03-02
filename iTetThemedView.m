//
//  iTetThemedView.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/13/09.
//

#import "iTetThemedView.h"
#import "iTetPreferencesController.h"

@implementation iTetThemedView

- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	// Set the initial theme from the preferences controller
	theme = [[[iTetPreferencesController preferencesController] currentTheme] retain];
	
	// Register as an observer for changes to the theme
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(currentThemeChanged:)
												 name:iTetCurrentThemeDidChangeNotification
											   object:nil];
	
	return self;
}

- (void)dealloc
{
	// De-register for notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// Release the theme
	[theme release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Theme Change Notification

- (void)currentThemeChanged:(NSNotification*)notification
{
	[self setTheme:[[iTetPreferencesController preferencesController] currentTheme]];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)acceptsFirstResponder
{
	// Themed views, by default, do not accept key input; the one exception is
	// the local player's board, implemented in iTetLocalBoardView
	return NO;
}

- (void)setTheme:(iTetTheme*)newTheme
{
	[self willChangeValueForKey:@"theme"];
	[newTheme retain];
	[theme release];
	theme = newTheme;
	[self didChangeValueForKey:@"theme"];
	
	[self setNeedsDisplay:YES];
}
@synthesize theme;

@end
