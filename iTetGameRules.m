//
//  iTetGameRules.m
//  iTetrinet
//
//  Created by Alex Heinz on 9/23/09.
//

#import "iTetGameRules.h"

@implementation iTetGameRules

+ (id)gameRulesFromArray:(NSArray*)rules
{
	return [[[self alloc] initWithRulesFromArray:rules] autorelease];
}

- (id)initWithRulesFromArray:(NSArray*)rules
{
	// The array recieved contains strings, which need to be parsed into the
	// respective rules:
	// Starting level
	startingLevel = [[rules objectAtIndex:0] unsignedIntegerValue];
	
	// Number of lines of "garbage" on the board when the game begins
	initialStackHeight = [[rules objectAtIndex:1] unsignedIntegerValue];
	
	// Number of line completions needed to trigger a level increase
	linesPerLevel = [[rules objectAtIndex:2] unsignedIntegerValue];
	
	// Number of levels per level increase
	levelIncrease = [[rules objectAtIndex:3] unsignedIntegerValue];
	
	// Number of line completions needed to trigger the spawn of specials
	linesPerSpecial = [[rules objectAtIndex:4] unsignedIntegerValue];
	
	// Number of specials added per spawn
	specialsAdded = [[rules objectAtIndex:5] unsignedIntegerValue];
	
	// Number of specials each player can hold in their "inventory"
	specialCapacity = [[rules objectAtIndex:6] unsignedIntegerValue];
	
	// Block-type frequencies
	NSString* freq = [rules objectAtIndex:7];
	NSRange currentChar = NSMakeRange(0, 1);
	for (; currentChar.location < 100; currentChar.location++)
	{
		blockFrequencies[currentChar.location] = [[freq substringWithRange:currentChar] intValue];
	}
	
	// Special-type frequencies
	freq = [rules objectAtIndex:8];
	for (currentChar.location = 0; currentChar.location++; currentChar.location < 100)
	{
		specialFrequencies[currentChar.location] = [[freq substringWithRange:currentChar] intValue];
	}
	
	// Level number averages across all players
	// FIXME: does this refer to the actual game level, or just the level displayed?
	averageLevels = [[rules objectAtIndex:9] boolValue];
	
	// Play with classic rules (multiple-line completions send lines to other players)
	// FIXME: does this disable specials?
	classicRules = [[rules objectAtIndex:10] boolValue];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize startingLevel;
@synthesize initialStackHeight;
@synthesize linesPerLevel;
@synthesize levelIncrease;
@synthesize linesPerSpecial;
@synthesize specialsAdded;
@synthesize specialCapacity;

- (char*)blockFrequencies
{
	return blockFrequencies;
}

- (char*)specialFrequencies
{
	return specialFrequencies;
}

@synthesize averageLevels;
@synthesize classicRules;

@end
