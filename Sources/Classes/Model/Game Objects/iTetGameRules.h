//
//  iTetGameRules.h
//  iTetrinet
//
//  Created by Alex Heinz on 9/23/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetServerInfo.h"

#define ITET_NUM_GAME_RULES_KEYS	16
extern NSString* const iTetGameRulesOfflineGameKey;
extern NSString* const iTetGameRulesGameTypeKey;
extern NSString* const iTetGameRulesGameVersionKey;
extern NSString* const iTetGameRulesInitialStackHeightKey;
extern NSString* const iTetGameRulesStartingLevelKey;
extern NSString* const iTetGameRulesLinesPerLevelKey;
extern NSString* const iTetGameRulesLevelIncreaseKey;
extern NSString* const iTetGameRulesSpecialsEnabledKey;
extern NSString* const iTetGameRulesLinesPerSpecialKey;
extern NSString* const iTetGameRulesSpecialsAddedKey;
extern NSString* const iTetGameRulesSpecialCapacityKey;
extern NSString* const iTetGameRulesCopyCollectedSpecialsKey;
extern NSString* const iTetGameRulesBlockFrequenciesKey;
extern NSString* const iTetGameRulesSpecialFrequenciesKey;
extern NSString* const iTetGameRulesShowAverageLevelKey;
extern NSString* const iTetGameRulesClassicRulesKey;
extern NSString* const iTetGameRulesBlockGeneratorSeedKey;

@interface iTetGameRules : NSObject

+ (NSMutableDictionary*)gameRulesFromArray:(NSArray*)rules
							  withGameType:(iTetProtocolType)protocol
							   gameVersion:(iTetGameVersion)version;

+ (NSMutableDictionary*)defaultOfflineGameRules;

+ (NSArray*)defaultOfflineBlockFrequencies;
+ (NSArray*)defaultOfflineSpecialFrequencies;

@end
