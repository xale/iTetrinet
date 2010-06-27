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
#import "iTetSpecials.h"
#import "NSDictionary+AdditionalTypes.h"

NSString* const iTetGameRulesOfflineGameKey =			@"iTetOfflineGame";
NSString* const iTetGameRulesGameTypeKey =				@"iTetGameType";
NSString* const iTetGameRulesInitialStackHeightKey =	@"iTetInitialStackHeight";
NSString* const iTetGameRulesStartingLevelKey =			@"iTetStartingLevel";
NSString* const iTetGameRulesLinesPerLevelKey =			@"iTetLinesPerLevel";
NSString* const iTetGameRulesLevelIncreaseKey =			@"iTetLevelIncrease";
NSString* const iTetGameRulesSpecialsEnabledKey =		@"iTetSpecialsEnabled";
NSString* const iTetGameRulesLinesPerSpecialKey =		@"iTetLinesPerSpecial";
NSString* const iTetGameRulesSpecialsAddedKey =			@"iTetSpecialsAdded";
NSString* const iTetGameRulesSpecialCapacityKey =		@"iTetSpecialCapacity";
NSString* const iTetGameRulesBlockFrequenciesKey =		@"iTetBlockFrequencies";
NSString* const iTetGameRulesSpecialFrequenciesKey =	@"iTetSpecialFrequencies";
NSString* const iTetGameRulesShowAverageLevelKey =		@"iTetShowAverageLevel";
NSString* const iTetGameRulesClassicRulesKey =			@"iTetClassicRules";

@implementation iTetGameRules

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

+ (NSMutableDictionary*)gameRulesFromArray:(NSArray*)rulesArray
							  withGameType:(iTetProtocolType)protocol
{
	// Create a dictionary to hold the rules
	NSMutableDictionary* rulesDict = [NSMutableDictionary dictionaryWithCapacity:ITET_NUM_GAME_RULES_KEYS];
	
	// Set the game type
	[rulesDict setBool:NO
				forKey:iTetGameRulesOfflineGameKey];
	[rulesDict setInt:protocol
			   forKey:iTetGameRulesGameTypeKey];
	
	// Create a decimal-number formatter
	NSNumberFormatter* decFormat = [[NSNumberFormatter alloc] init];
	[decFormat setNumberStyle:NSNumberFormatterDecimalStyle];
	
	// The game-rules array contains strings, which need to be parsed into the respective rules:
	// Number of lines of "garbage" on the board when the game begins
	[rulesDict setObject:[decFormat numberFromString:[rulesArray objectAtIndex:0]]
				  forKey:iTetGameRulesInitialStackHeightKey];
	
	// Starting level
	[rulesDict setObject:[decFormat numberFromString:[rulesArray objectAtIndex:1]]
				  forKey:iTetGameRulesStartingLevelKey];
	
	// Number of line completions needed to trigger a level increase
	[rulesDict setObject:[decFormat numberFromString:[rulesArray objectAtIndex:2]]
				  forKey:iTetGameRulesLinesPerLevelKey];
	
	// Number of levels per level increase
	[rulesDict setObject:[decFormat numberFromString:[rulesArray objectAtIndex:3]]
				  forKey:iTetGameRulesLevelIncreaseKey];
	
	// Number of line completions needed to trigger the spawn of specials
	[rulesDict setObject:[decFormat numberFromString:[rulesArray objectAtIndex:4]]
				  forKey:iTetGameRulesLinesPerSpecialKey];
	
	// Number of specials added per spawn
	[rulesDict setObject:[decFormat numberFromString:[rulesArray objectAtIndex:5]]
				  forKey:iTetGameRulesSpecialsAddedKey];
	
	// Check whether specials are enabled
	[rulesDict setBool:(([rulesDict integerForKey:iTetGameRulesLinesPerSpecialKey] > 0) && ([rulesDict integerForKey:iTetGameRulesSpecialsAddedKey] > 0))
				forKey:iTetGameRulesSpecialsEnabledKey];
	
	// Number of specials each player can hold in their "inventory"
	[rulesDict setObject:[decFormat numberFromString:[rulesArray objectAtIndex:6]]
				  forKey:iTetGameRulesSpecialCapacityKey];
	
	// Block-type frequencies
	NSMutableArray* temp = [NSMutableArray arrayWithCapacity:100];
	NSString* freq = [rulesArray objectAtIndex:7];
	NSRange currentChar = NSMakeRange(0, 1);
	for (; currentChar.location < 100; currentChar.location++)
	{
		[temp addObject:[decFormat numberFromString:[freq substringWithRange:currentChar]]];
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
				forKey:iTetGameRulesShowAverageLevelKey];
	
	// Release the number formatter
	[decFormat release];
	
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
	
	// TetriFast-style
	[rulesDict setInt:tetrifastProtocol
			   forKey:iTetGameRulesGameTypeKey];
	
	// No garbage
	[rulesDict setInteger:0
				   forKey:iTetGameRulesInitialStackHeightKey];
	
	// Starting level one, five lines per level, one level advance at a time
	[rulesDict setInteger:1
				   forKey:iTetGameRulesStartingLevelKey];
	[rulesDict setInteger:5
				   forKey:iTetGameRulesLinesPerLevelKey];
	[rulesDict setInteger:1
				   forKey:iTetGameRulesLevelIncreaseKey];
	
	// Two lines per special, one added at a time, queue capacity of 20
	[rulesDict setBool:YES
				forKey:iTetGameRulesSpecialsEnabledKey];
	[rulesDict setInteger:2
				   forKey:iTetGameRulesLinesPerSpecialKey];
	[rulesDict setInteger:1
				   forKey:iTetGameRulesSpecialsAddedKey];
	[rulesDict setInteger:20
				   forKey:iTetGameRulesSpecialCapacityKey];
	
	// Disable the average level indicator (since this is meaningless)
	[rulesDict setBool:NO
				forKey:iTetGameRulesShowAverageLevelKey];
	
	// Disable classic rules (again, this is irrelevant)
	[rulesDict setBool:NO
				forKey:iTetGameRulesClassicRulesKey];
	
	// Even block distribution
	NSMutableArray* temp = [NSMutableArray arrayWithCapacity:100];
	for (NSInteger i = 0; i < 100; i++)
	{
		[temp addObject:[NSNumber numberWithInt:((random() % 7) + 1)]];
	}
	[rulesDict setObject:[NSArray arrayWithArray:temp]
				  forKey:iTetGameRulesBlockFrequenciesKey];
	
	// FIXME: disable bad specials, switchfield
	[temp removeAllObjects];
	for (NSInteger i = 0; i < 100; i++)
	{
		[temp addObject:[NSNumber numberWithInt:[iTetSpecials specialTypeForNumber:((random() % 9) + 1)]]];	
	}
	[rulesDict setObject:[NSArray arrayWithArray:temp]
				  forKey:iTetGameRulesSpecialFrequenciesKey];
	
	// Return the dictionary of rules
	return rulesDict;
}

@end
