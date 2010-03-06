//
//  iTetGameRules.m
//  iTetrinet
//
//  Created by Alex Heinz on 9/23/09.
//

#import "iTetGameRules.h"
#import "iTetSpecials.h"

@implementation iTetGameRules

+ (id)gameRulesFromArray:(NSArray*)rules
			withGameType:(iTetProtocolType)protocol
{
	return [[[self alloc] initWithRulesFromArray:rules
									withGameType:protocol] autorelease];
}

- (id)initWithRulesFromArray:(NSArray*)rules
				withGameType:(iTetProtocolType)protocol
{
	// Set the game type
	gameType = protocol;
	
	// The array recieved contains strings, which need to be parsed into the
	// respective rules:
	// Number of lines of "garbage" on the board when the game begins
	initialStackHeight = [[rules objectAtIndex:0] integerValue];
	
	// Starting level
	startingLevel = [[rules objectAtIndex:1] integerValue];
	
	// Number of line completions needed to trigger a level increase
	linesPerLevel = [[rules objectAtIndex:2] integerValue];
	
	// Number of levels per level increase
	levelIncrease = [[rules objectAtIndex:3] integerValue];
	
	// Number of line completions needed to trigger the spawn of specials
	linesPerSpecial = [[rules objectAtIndex:4] integerValue];
	
	// Number of specials added per spawn
	specialsAdded = [[rules objectAtIndex:5] integerValue];
	
	// Number of specials each player can hold in their "inventory"
	specialCapacity = [[rules objectAtIndex:6] integerValue];
	
	// Block-type frequencies
	NSString* freq = [rules objectAtIndex:7];
	NSRange currentChar = NSMakeRange(0, 1);
	for (; currentChar.location < 100; currentChar.location++)
	{
		blockFrequencies[currentChar.location] = (uint8_t)[[freq substringWithRange:currentChar] intValue];
	}
	
	// Special-type frequencies
	freq = [rules objectAtIndex:8];
	for (currentChar.location = 0; currentChar.location < 100; currentChar.location++)
	{
		specialFrequencies[currentChar.location] = [iTetSpecials specialTypeForNumber:[[freq substringWithRange:currentChar] intValue]];
	}
	
	// Level number averages across all players
	showAverageLevel = [[rules objectAtIndex:9] boolValue];
	
	// Play with classic rules (multiple-line completions send lines to other players)
	classicRules = [[rules objectAtIndex:10] boolValue];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize gameType;
@synthesize startingLevel;
@synthesize initialStackHeight;
@synthesize linesPerLevel;
@synthesize levelIncrease;
@synthesize linesPerSpecial;
@synthesize specialsAdded;
@synthesize specialCapacity;

- (uint8_t*)blockFrequencies
{
	return blockFrequencies;
}

- (iTetSpecialType*)specialFrequencies
{
	return specialFrequencies;
}

@synthesize showAverageLevel;
@synthesize classicRules;

@end
