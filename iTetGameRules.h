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
#import "iTetSpecials.h"

@interface iTetGameRules : NSObject
{
	iTetProtocolType gameType;
	NSUInteger startingLevel;
	NSUInteger initialStackHeight;
	NSUInteger linesPerLevel;
	NSUInteger levelIncrease;
	NSUInteger linesPerSpecial;
	NSUInteger specialsAdded;
	NSUInteger specialCapacity;
	NSArray* blockFrequencies;
	NSArray* specialFrequencies;
	BOOL showAverageLevel;
	BOOL classicRules;
}

+ (id)gameRulesFromArray:(NSArray*)rules
			withGameType:(iTetProtocolType)protocol;
- (id)initWithRulesFromArray:(NSArray*)rules
				withGameType:(iTetProtocolType)protocol;

+ (id)offlineGameRules;
- (id)initWithOfflineGameRules;

@property (readonly) iTetProtocolType gameType;
@property (readonly) NSUInteger startingLevel;
@property (readonly) NSUInteger initialStackHeight;
@property (readonly) NSUInteger linesPerLevel;
@property (readonly) NSUInteger levelIncrease;
@property (readonly) NSUInteger linesPerSpecial;
@property (readonly) NSUInteger specialsAdded;
@property (readonly) NSUInteger specialCapacity;
@property (readonly) NSArray* blockFrequencies;
@property (readonly) NSArray* specialFrequencies;
@property (readonly) BOOL showAverageLevel;
@property (readonly) BOOL classicRules;

@end
