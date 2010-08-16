//
//  iTetLocalPlayer.m
//  iTetrinet
//
//  Created by Alex Heinz on 1/28/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetLocalPlayer.h"
#import "iTetField.h"
#import "iTetBlock.h"

@implementation iTetLocalPlayer

- (void)dealloc
{
	[currentBlock release];
	[nextBlock release];
	[specialsQueue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isLocalPlayer
{
	return YES;
}

- (void)setField:(iTetField*)newField
{
	// Check that the new field has calculated its field deltas
	if (([newField updateFieldstring] == nil) || IPSEqualRegions([newField updateDirtyRegion], iTetUnknownDirtyRegion))
	{
		// Calculate the deltas relative to the old field
		if (field != nil)
			[newField setUpdateDeltasFromField:field];
		else
			[newField setUpdateDeltasFromField:[iTetField field]];
	}
	
	// Swap in the new field
	[newField retain];
	[field release];
	field = newField;
}

#pragma mark Lines

- (void)addLines:(NSInteger)lines
{
	[self setLinesCleared:([self linesCleared] + lines)];
	[self setLinesSinceLastLevel:([self linesSinceLastLevel] + lines)];
	[self setLinesSinceLastSpecials:([self linesSinceLastSpecials] + lines)];
}

- (void)resetLinesCleared
{
	[self setLinesCleared:0];
	[self setLinesSinceLastLevel:0];
	[self setLinesSinceLastSpecials:0];
}

@synthesize linesCleared;
@synthesize linesSinceLastLevel;
@synthesize linesSinceLastSpecials;

#pragma mark Specials

- (void)addSpecialToQueue:(NSNumber*)special
{
	// Choose a random index between zero and the end of the queue, inclusive
	NSInteger index = random() % ([specialsQueue count] + 1);
	
	[self willChangeValueForKey:@"specialsQueue"];
	
	// Add the special to the queue at the random index
	[[self specialsQueue] insertObject:special
							   atIndex:index];
	
	[self didChangeValueForKey:@"specialsQueue"];
}

- (NSNumber*)dequeueNextSpecial
{
	// Treat the end of the array as the "front" of the queue
	// Get the next special from the queue
	NSNumber* special = [[self specialsQueue] lastObject];
	
	[self willChangeValueForKey:@"specialsQueue"];
	
	// Remove the special from the queue
	[[self specialsQueue] removeLastObject];
	
	[self didChangeValueForKey:@"specialsQueue"];
	
	// Return the special
	return special;
}

- (void)setSpecialsQueue:(NSMutableArray*)specials
{
	// The specialsQueue key uses manual KVO notifications, so we have to implement this ourselves
	[self willChangeValueForKey:@"specialsQueue"];
	
	// Retain new...
	[specials retain];
	
	// ...release old...
	[specialsQueue release];
	
	// ...and swap
	specialsQueue = specials;
	
	[self didChangeValueForKey:@"specialsQueue"];
}
@synthesize specialsQueue;

- (NSNumber*)nextSpecial
{
	return [[self specialsQueue] lastObject];
}

#pragma mark Blocks

@synthesize currentBlock;
@synthesize nextBlock;

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	if ([key isEqualToString:@"specialsQueue"])
		return NO;
	
	return [super automaticallyNotifiesObserversForKey:key];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	NSSet* keys = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"nextSpecial"])
		keys = [keys setByAddingObject:@"specialsQueue"];
	
	return keys;
}

@end
