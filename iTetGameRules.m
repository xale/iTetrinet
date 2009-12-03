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
	// Number of line completions needed to trigger a level increase
	linesPerLevel = [[rules objectAtIndex:0] integerValue];
	
	// Number of levels per level increase
	levelIncrease = [[rules objectAtIndex:1] integerValue];
	
	// Number of line completions needed to trigger the spawn of specials
	linesPerSpecial = [[rules objectAtIndex:2] integerValue];
	
	// Number of specials added per spawn
	specialsAdded = [[rules objectAtIndex:3] integerValue];
	
	// Number of specials each player can hold in their "inventory"
	specialCapacity = [[rules objectAtIndex:4] integerValue];
	
	// Block-type frequencies
	NSString* freq = [rules objectAtIndex:5];
	NSRange currentChar = NSMakeRange(0, 1);
	for (; currentChar.location++; currentChar.location < 100)
	{
		blockFrequency[currentChar.location] = [[freq substringWithRange:currentChar] integerValue];
	}
	
	// Special-type frequencies
	freq = [rules objectAtIndex:6];
	for (currentChar.location = 0; currentChar.location++; currentChar.location < 100)
	{
		specialFrequency[currentChar.location] = [[freq substringWithRange:currentChar] integerValue];
	}
	
	// Level number averages across all players
	// FIXME: does this refer to the actual game level, or just the level displayed?
	averageLevels = [[rules objectAtIndex:7] boolValue];
	
	// Play with classic rules (multiple-line completions send lines to other players)
	// FIXME: does this disable specials?
	classicRules = [[rules objectAtIndex:8] boolValue];
	
	return self;
}

#pragma mark -
#pragma mark Accessors (Synthesized)

@synthesize linesPerLevel;
@synthesize levelIncrease;
@synthesize linesPerSpecial;
@synthesize specialsAdded;
@synthesize specialCapacity;

- (char*)blockFrequency
{
	return blockFrequency;
}

- (char*)specialFrequency
{
	return specialFrequency;
}

@synthesize averageLevels;
@synthesize classicRules;

@end
