//
//  iTetGameRules.m
//  iTetrinet
//
//  Created by Alex Heinz on 9/23/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGameRules.h"
#import "iTetBlock.h"
#import "iTetSpecials.h"
#import "NSDictionary+AdditionalTypes.h"

NSString* const iTetGameRulesOfflineGameKey =			@"iTetOfflineGame";
NSString* const iTetGameRulesGameTypeKey =				@"iTetGameType";
NSString* const iTetGameRulesGameVersionKey =			@"iTetGameVersion";
NSString* const iTetGameRulesInitialStackHeightKey =	@"iTetInitialStackHeight";
NSString* const iTetGameRulesStartingLevelKey =			@"iTetStartingLevel";
NSString* const iTetGameRulesLinesPerLevelKey =			@"iTetLinesPerLevel";
NSString* const iTetGameRulesLevelIncreaseKey =			@"iTetLevelIncrease";
NSString* const iTetGameRulesSpecialsEnabledKey =		@"iTetSpecialsEnabled";
NSString* const iTetGameRulesLinesPerSpecialKey =		@"iTetLinesPerSpecial";
NSString* const iTetGameRulesSpecialsAddedKey =			@"iTetSpecialsAdded";
NSString* const iTetGameRulesSpecialCapacityKey =		@"iTetSpecialCapacity";
NSString* const iTetGameRulesCopyCollectedSpecialsKey =	@"iTetCopyCollectedSpecials";
NSString* const iTetGameRulesBlockFrequenciesKey =		@"iTetBlockFrequencies";
NSString* const iTetGameRulesSpecialFrequenciesKey =	@"iTetSpecialFrequencies";
NSString* const iTetGameRulesShowAverageLevelKey =		@"iTetShowAverageLevel";
NSString* const iTetGameRulesClassicRulesKey =			@"iTetClassicRules";
NSString* const iTetGameRulesBlockGeneratorSeedKey =	@"iTetBlockGeneratorSeed";

@implementation iTetGameRules

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

+ (NSMutableDictionary*)gameRulesFromArray:(NSArray*)rulesArray
							  withGameType:(iTetProtocolType)protocol
							   gameVersion:(iTetGameVersion)version
{
	// Create a dictionary to hold the rules
	NSMutableDictionary* rulesDict = [NSMutableDictionary dictionaryWithCapacity:ITET_NUM_GAME_RULES_KEYS];
	
	// Set the game type
	[rulesDict setBool:NO
				forKey:iTetGameRulesOfflineGameKey];
	[rulesDict setInt:protocol
			   forKey:iTetGameRulesGameTypeKey];
	[rulesDict setInt:version
			   forKey:iTetGameRulesGameVersionKey];
	
	// Create a decimal-number formatter
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	// The game-rules array contains strings, which need to be parsed into the respective rules:
	// Number of lines of "garbage" on the field when the game begins
	[rulesDict setObject:[formatter numberFromString:[rulesArray objectAtIndex:0]]
				  forKey:iTetGameRulesInitialStackHeightKey];
	
	// Starting level
	[rulesDict setObject:[formatter numberFromString:[rulesArray objectAtIndex:1]]
				  forKey:iTetGameRulesStartingLevelKey];
	
	// Number of line completions needed to trigger a level increase
	[rulesDict setObject:[formatter numberFromString:[rulesArray objectAtIndex:2]]
				  forKey:iTetGameRulesLinesPerLevelKey];
	
	// Number of levels per level increase
	[rulesDict setObject:[formatter numberFromString:[rulesArray objectAtIndex:3]]
				  forKey:iTetGameRulesLevelIncreaseKey];
	
	// Number of line completions needed to trigger the spawn of specials
	[rulesDict setObject:[formatter numberFromString:[rulesArray objectAtIndex:4]]
				  forKey:iTetGameRulesLinesPerSpecialKey];
	
	// Number of specials added per spawn
	[rulesDict setObject:[formatter numberFromString:[rulesArray objectAtIndex:5]]
				  forKey:iTetGameRulesSpecialsAddedKey];
	
	// Check whether specials are enabled
	[rulesDict setBool:(([rulesDict integerForKey:iTetGameRulesLinesPerSpecialKey] > 0) && ([rulesDict integerForKey:iTetGameRulesSpecialsAddedKey] > 0))
				forKey:iTetGameRulesSpecialsEnabledKey];
	
	// Make sure specials get copied when the player clears multiple lines
	[rulesDict setBool:YES
				forKey:iTetGameRulesCopyCollectedSpecialsKey];
	
	// Number of specials each player can hold in their "inventory"
	[rulesDict setObject:[formatter numberFromString:[rulesArray objectAtIndex:6]]
				  forKey:iTetGameRulesSpecialCapacityKey];
	
	// Block-type frequencies
	NSMutableArray* temp = [NSMutableArray arrayWithCapacity:100];
	NSString* freq = [rulesArray objectAtIndex:7];
	NSRange currentChar = NSMakeRange(0, 1);
	for (; currentChar.location < 100; currentChar.location++)
	{
		iTetBlockType blockType = (iTetBlockType)([[freq substringWithRange:currentChar] intValue] - 1);
		[temp addObject:[NSNumber numberWithInt:blockType]];
	}
	[rulesDict setObject:[NSArray arrayWithArray:temp]
				  forKey:iTetGameRulesBlockFrequenciesKey];
	
	// Special-type frequencies
	[temp removeAllObjects];
	freq = [rulesArray objectAtIndex:8];
	for (currentChar.location = 0; currentChar.location < 100; currentChar.location++)
	{
		[temp addObject:[NSNumber numberWithInt:[iTetSpecials specialTypeForNumber:[[freq substringWithRange:currentChar] intValue]]]];
	}
	[rulesDict setObject:[NSArray arrayWithArray:temp]
				  forKey:iTetGameRulesSpecialFrequenciesKey];
	
	// Level number averages across all players
	[rulesDict setBool:[[rulesArray objectAtIndex:9] boolValue]
				forKey:iTetGameRulesShowAverageLevelKey];
	
	// Play with classic rules (multiple-line completions send lines to other players)
	[rulesDict setBool:[[rulesArray objectAtIndex:10] boolValue]
				forKey:iTetGameRulesClassicRulesKey];
	
	// Block-generator seed (if applicable)
	if (version == version114)
	{
		NSUInteger seed;
		
		// Check that the server has supplied us with a seed
		if ([rulesArray count] >= 12)
		{
			// Attempt to parse the hexadecimal seed
			unsigned long long temp;
			BOOL success = [[NSScanner scannerWithString:[rulesArray objectAtIndex:11]] scanHexLongLong:&temp];
			
			// Check that the seed parsed properly
			if (success)
			{
				seed = temp;
			}
			else
			{
				// If we can't read the seed sent by the server, print a warning and use a random seed
				NSLog(@"warning: could not parse block-generator seed supplied by server: %@", [rulesArray objectAtIndex:11]);
				seed = random();
			}
		}
		else
		{
			// If the server did not supply us with a seed, print a warning and use a random seed
			NSLog(@"warning: no block-generator seed supplied by server with newgame message");
			seed = random();
		}
		
		[rulesDict setUnsignedInteger:seed
							   forKey:iTetGameRulesBlockGeneratorSeedKey];
	}
	
	// Release the number formatter
	[formatter release];
	
	// Return the dictionary of rules
	return rulesDict;
}

+ (NSMutableDictionary*)defaultOfflineGameRules
{
	// Create a rules dictionary
	NSMutableDictionary* rulesDict = [NSMutableDictionary dictionaryWithCapacity:ITET_NUM_GAME_RULES_KEYS];
	
	// Default offline game rules:
	[rulesDict setBool:YES
				forKey:iTetGameRulesOfflineGameKey];
	
	// Tetrifast-style, normal random()-based block selection
	[rulesDict setInt:tetrifastProtocol
			   forKey:iTetGameRulesGameTypeKey];
	[rulesDict setInt:version113
			   forKey:iTetGameRulesGameVersionKey];
	
	// No garbage
	[rulesDict setInteger:0
				   forKey:iTetGameRulesInitialStackHeightKey];
	
	// Starting level one, five lines per level, three-level increase per level-up
	[rulesDict setInteger:1
				   forKey:iTetGameRulesStartingLevelKey];
	[rulesDict setInteger:5
				   forKey:iTetGameRulesLinesPerLevelKey];
	[rulesDict setInteger:3
				   forKey:iTetGameRulesLevelIncreaseKey];
	
	// Five lines per special, one added at a time, queue capacity of ten
	[rulesDict setBool:YES
				forKey:iTetGameRulesSpecialsEnabledKey];
	[rulesDict setInteger:5
				   forKey:iTetGameRulesLinesPerSpecialKey];
	[rulesDict setInteger:1
				   forKey:iTetGameRulesSpecialsAddedKey];
	[rulesDict setInteger:10
				   forKey:iTetGameRulesSpecialCapacityKey];
	
	// Disable copying collected specials when multiple lines are cleared
	[rulesDict setBool:NO
				forKey:iTetGameRulesCopyCollectedSpecialsKey];
	
	// Even block distribution
	[rulesDict setObject:[self defaultOfflineBlockFrequencies]
				  forKey:iTetGameRulesBlockFrequenciesKey];
	
	// Predetermined "offline mode" specials distribution
	[rulesDict setObject:[self defaultOfflineSpecialFrequencies]
				  forKey:iTetGameRulesSpecialFrequenciesKey];
	
	// Disable the average level indicator (since this is meaningless)
	[rulesDict setBool:NO
				forKey:iTetGameRulesShowAverageLevelKey];
	
	// Enable "classic rules" (this allows us to record multiple-line clears)
	[rulesDict setBool:YES
				forKey:iTetGameRulesClassicRulesKey];
	
	// Return the dictionary of rules
	return rulesDict;
}

+ (NSArray*)defaultOfflineBlockFrequencies
{
	// Create an empty array
	NSMutableArray* frequencies = [NSMutableArray arrayWithCapacity:100];
	iTetBlockType blockType = 0;
	
	// Add an equal fraction of each type of block
	while ([frequencies count] < 100)
	{
		[frequencies addObject:[NSNumber numberWithInt:blockType]];
		blockType = ((blockType + 1) % ITET_NUM_BLOCK_TYPES);
	}
	
	return [NSArray arrayWithArray:frequencies];
}

+ (NSArray*)defaultOfflineSpecialFrequencies
{
	// Create an empty array
	NSMutableArray* frequencies = [NSMutableArray arrayWithCapacity:100];
	
	// Add specific quantities of the "good" types of specials
	// Clearline (most common)
	for (NSInteger count = 0; count < 80; count++)
		[frequencies addObject:[NSNumber numberWithInt:clearLine]];
	// Nuke and gravity (rarer)
	for (NSInteger count = 0; count < 10; count++)
		[frequencies addObject:[NSNumber numberWithInt:nukeField]];
	for (NSInteger count = 0; count < 10; count++)
		[frequencies addObject:[NSNumber numberWithInt:gravity]];
	
	return [NSArray arrayWithArray:frequencies];
}

@end
