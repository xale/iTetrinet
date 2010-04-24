//
//  iTetThemesArrayController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/28/09.
//

#import "iTetThemesArrayController.h"
#import "iTetTheme.h"

@implementation iTetThemesArrayController

#pragma mark -
#pragma mark Accessors/Properties

- (iTetTheme*)selectedTheme
{
	// Get the array of selected objects
	NSArray* selection = [self selectedObjects];
	
	// Check that there is exactly one theme selected
	if ([selection count] != 1)
		return nil;
	
	// Otherwise, return the selected theme
	return [selection objectAtIndex:0];
}

- (void)addObject:(id)object
{
	iTetTheme* theme = (iTetTheme*)object;
	[theme copyFiles];
	
	[super addObject:object];
}

- (void)removeObjectAtArrangedObjectIndex:(NSUInteger)index
{
	iTetTheme* theme = [[self arrangedObjects] objectAtIndex:index];
	[theme deleteFiles];
	
	[super removeObjectAtArrangedObjectIndex:index];
}

- (BOOL)canRemove
{
	// Get the selected theme
	iTetTheme* selection = [self selectedTheme];
	
	// Check that the selection is valid
	if (selection == nil)
		return NO;
	
	// Check that the selected theme is not one of the default themes
	if ([[iTetTheme defaultThemes] containsObject:selection])
		return NO;
	
	return YES;
}

@end
