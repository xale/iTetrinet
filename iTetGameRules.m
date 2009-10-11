//
//  iTetGameRules.m
//  iTetrinet
//
//  Created by Alex Heinz on 9/23/09.
//

#import "iTetGameRules.h"


@implementation iTetGameRules

- (id)initWithRules:(NSArray*)rules
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
	// FIXME: What does this actually do?
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
	
	// Display level number as average of all players
	// FIXME: What does this actually do?
	averageLevels = [[rules objectAtIndex:7] boolValue];
	
	// Play with classic rules (multiple-line completions send lines to the
	// enemy; specials are disabled)
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
