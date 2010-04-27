//
//  iTetThemesArrayController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/28/09.
//

#import "iTetThemesArrayController.h"
#import "iTetTheme.h"

@implementation iTetThemesArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// Search the theme list for any themes that failed to load
	NSMutableIndexSet* failedIndexes = [NSMutableIndexSet indexSet];
	for (NSUInteger index = 0; index < [[self arrangedObjects] count]; index++)
	{
		if ([[self arrangedObjects] objectAtIndex:index] == [NSNull null])
			[failedIndexes addIndex:index];
	}
	
	// Clean out failed themes
	[self removeObjectsAtArrangedObjectIndexes:failedIndexes];
}

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
	if ([object isKindOfClass:[iTetTheme class]])
	{
		iTetTheme* addedTheme = (iTetTheme*)object;
		[addedTheme copyFiles];
	}
	
	[super addObject:object];
}

- (void)removeObject:(id)object
{
	if ([object isKindOfClass:[iTetTheme class]])
	{
		iTetTheme* themeToRemove = (iTetTheme*)object;
		[themeToRemove deleteFiles];
	}
	
	[super removeObject:object];
}

- (void)removeObjectAtArrangedObjectIndex:(NSUInteger)index
{
	id objectToRemove = [[self arrangedObjects] objectAtIndex:index];
	if ([objectToRemove isKindOfClass:[iTetTheme class]])
	{
		iTetTheme* themeToRemove = (iTetTheme*)objectToRemove;
		[themeToRemove deleteFiles];
	}
	
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
