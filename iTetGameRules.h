//
//  iTetGameRules.h
//  iTetrinet
//
//  Created by Alex Heinz on 9/23/09.
//

#import <Cocoa/Cocoa.h>

@interface iTetGameRules : NSObject
{
	NSUInteger linesPerLevel;
	NSUInteger levelIncrease;
	NSUInteger linesPerSpecial;
	NSUInteger specialsAdded;
	NSUInteger specialCapacity;
	char blockFrequency[100];
	char specialFrequency[100];
	BOOL averageLevels;
	BOOL classicRules;
}

+ (id)gameRulesFromArray:(NSArray*)rules;
- (id)initWithRulesFromArray:(NSArray*)rules;

@property (readonly) NSUInteger linesPerLevel;
@property (readonly) NSUInteger levelIncrease;
@property (readonly) NSUInteger linesPerSpecial;
@property (readonly) NSUInteger specialsAdded;
@property (readonly) NSUInteger specialCapacity;
@property (readonly) char* blockFrequency;
@property (readonly) char* specialFrequency;
@property (readonly) BOOL averageLevels;
@property (readonly) BOOL classicRules;

@end
