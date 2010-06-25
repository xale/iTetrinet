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
	
	// The array recieved contains strings, which need to be parsed into the respective rules:
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
	NSMutableArray* temp = [NSMutableArray arrayWithCapacity:100];
	NSString* freq = [rules objectAtIndex:7];
	NSRange currentChar = NSMakeRange(0, 1);
	for (; currentChar.location < 100; currentChar.location++)
	{
		[temp addObject:[NSNumber numberWithInt:[[freq substringWithRange:currentChar] intValue]]];
	}
	blockFrequencies = [temp copy];
	
	// Special-type frequencies
	[temp removeAllObjects];
	freq = [rules objectAtIndex:8];
	for (currentChar.location = 0; currentChar.location < 100; currentChar.location++)
	{
		[temp addObject:[NSNumber numberWithInt:[iTetSpecials specialTypeForNumber:[[freq substringWithRange:currentChar] intValue]]]];
	}
	specialFrequencies = [temp copy];
	
	// Level number averages across all players
	showAverageLevel = [[rules objectAtIndex:9] boolValue];
	
	// Play with classic rules (multiple-line completions send lines to other players)
	classicRules = [[rules objectAtIndex:10] boolValue];
	
	return self;
}

+ (id)offlineGameRules
{
	return [[[self alloc] initWithOfflineGameRules] autorelease];
}

- (id)initWithOfflineGameRules
{
	// FIXME: This information should be user-configurable, and stored in user defaults
	gameType = tetrifastProtocol;
	initialStackHeight = 0;
	startingLevel = 1;
	linesPerLevel = 10;
	levelIncrease = 1;
	linesPerSpecial = 2;
	specialsAdded = 1;
	specialCapacity = 20;
	showAverageLevel = NO;
	classicRules = NO;
	
	NSMutableArray* temp = [NSMutableArray arrayWithCapacity:100];
	for (NSInteger i = 0; i < 100; i++)
		[temp addObject:[NSNumber numberWithInt:((random() % 7) + 1)]];
	blockFrequencies = [temp copy];
	
	temp = [NSMutableArray arrayWithCapacity:100];
	for (NSInteger i = 0; i < 100; i++)
		[temp addObject:[NSNumber numberWithInt:[iTetSpecials specialTypeForNumber:((random() % 9) + 1)]]];
	specialFrequencies = [temp copy];
	
	return self;
}

- (void)dealloc
{
	[blockFrequencies release];
	[specialFrequencies release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize gameType;
@synthesize initialStackHeight;
@synthesize startingLevel;
@synthesize linesPerLevel;
@synthesize levelIncrease;
@synthesize linesPerSpecial;
@synthesize specialsAdded;
@synthesize specialCapacity;
@synthesize blockFrequencies;
@synthesize specialFrequencies;
@synthesize showAverageLevel;
@synthesize classicRules;

@end
