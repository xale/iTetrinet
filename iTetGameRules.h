//
//  iTetGameRules.h
//  iTetrinet
//
//  Created by Alex Heinz on 9/23/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetServerInfo.h"

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
	char blockFrequencies[100];
	char specialFrequencies[100];
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
@property (readonly) char* blockFrequencies;
@property (readonly) char* specialFrequencies;
@property (readonly) BOOL showAverageLevel;
@property (readonly) BOOL classicRules;

@end
