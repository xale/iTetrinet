//
//  iTetThemesArrayController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/28/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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
		iTetTheme* themeToAdd = (iTetTheme*)object;
		[themeToAdd copyFilesToSupportDirectory];
	}
	
	[super addObject:object];
}

- (void)removeObject:(id)object
{
	if ([object isKindOfClass:[iTetTheme class]])
	{
		iTetTheme* themeToRemove = (iTetTheme*)object;
		[themeToRemove removeFilesFromSupportDirectory];
	}
	
	[super removeObject:object];
}

- (void)replaceTheme:(iTetTheme*)oldTheme
		   withTheme:(iTetTheme*)newTheme
{
	// Remove the old theme; do not remove old theme's files, in case they are already in the right place for the old theme
	[super removeObject:oldTheme];
	
	// Add the new theme
	[self addObject:newTheme];
}

- (void)removeObjectAtArrangedObjectIndex:(NSUInteger)index
{
	id objectToRemove = [[self arrangedObjects] objectAtIndex:index];
	if ([objectToRemove isKindOfClass:[iTetTheme class]])
	{
		iTetTheme* themeToRemove = (iTetTheme*)objectToRemove;
		[themeToRemove removeFilesFromSupportDirectory];
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
