//
//  iTetGameRules.h
//  iTetrinet
//
//  Created by Alex Heinz on 9/23/09.
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
	uint8_t blockFrequencies[100];
	iTetSpecialType specialFrequencies[100];
	BOOL showAverageLevel;
	BOOL classicRules;
}

+ (id)gameRulesFromArray:(NSArray*)rules
			withGameType:(iTetProtocolType)protocol;
- (id)initWithRulesFromArray:(NSArray*)rules
				withGameType:(iTetProtocolType)protocol;

@property (readonly) iTetProtocolType gameType;
@property (readonly) NSUInteger startingLevel;
@property (readonly) NSUInteger initialStackHeight;
@property (readonly) NSUInteger linesPerLevel;
@property (readonly) NSUInteger levelIncrease;
@property (readonly) NSUInteger linesPerSpecial;
@property (readonly) NSUInteger specialsAdded;
@property (readonly) NSUInteger specialCapacity;
@property (readonly) uint8_t* blockFrequencies;
@property (readonly) iTetSpecialType* specialFrequencies;
@property (readonly) BOOL showAverageLevel;
@property (readonly) BOOL classicRules;

@end
