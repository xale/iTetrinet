//
//  NSNumber+iTetSpecials.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/8/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#include "NSNumber+iTetSpecials.h"

#define iTetAddLineSpecialName			NSLocalizedStringFromTable(@"Add Line", @"Specials", @"Name of the 'add line' special block")
#define iTetClearLineSpecialName		NSLocalizedStringFromTable(@"Clear Line", @"Specials", @"Name of the 'clear line' special block")
#define iTetNukeFieldSpecialName		NSLocalizedStringFromTable(@"Nuke Field", @"Specials", @"Name of the 'nuke field' special block")
#define iTetRandomClearSpecialName		NSLocalizedStringFromTable(@"Random Clear", @"Specials", @"Name of the 'random clear' special block")
#define iTetSwitchFieldSpecialName		NSLocalizedStringFromTable(@"Switch Field", @"Specials", @"Name of the 'switch field' special block")
#define iTetClearSpecialsSpecialName	NSLocalizedStringFromTable(@"Clear Specials", @"Specials", @"Name of the 'clear specials' special block")
#define iTetGravitySpecialName			NSLocalizedStringFromTable(@"Gravity", @"Specials", @"Name of the 'gravity' special block")
#define iTetQuakeFieldSpecialName		NSLocalizedStringFromTable(@"Quake Field", @"Specials", @"Name of the 'quake field' special block")
#define iTetBlockBombSpecialName		NSLocalizedStringFromTable(@"Block Bomb", @"Specials", @"Name of the 'block bomb' special block")
#define iTetInvalidOrNoneSpecialName	NSLocalizedStringFromTable(@"No Special", @"Specials", @"Placeholder name for null or invalid specials")

NSString* const iTetClassicStyleAddSpecialPrefix = @"cs";

@implementation NSNumber (iTetSpecials)

+ (NSNumber*)numberWithSpecialType:(iTetSpecialType)specialType
{
	return [NSNumber numberWithInt:specialType];
}

+ (NSNumber*)numberWithSpecialFromCellValue:(uint8_t)specialCellValue;
{
	switch ((iTetSpecialType)specialCellValue)
	{
		case addLine:
		case clearLine:
		case nukeField:
		case randomClear:
		case switchField:
		case clearSpecials:
		case gravity:
		case quakeField:
		case blockBomb:
			return [NSNumber numberWithInt:(iTetSpecialType)specialCellValue];
		default:
			break;
	}
	
	return [NSNumber numberWithInt:invalidSpecial];
}

+ (NSNumber*)numberWithSpecialAtIndexNumber:(uint8_t)specialNumber;
{
	switch (specialNumber)
	{
		case 1:
			return [NSNumber numberWithInt:addLine];
		case 2:
			return [NSNumber numberWithInt:clearLine];
		case 3:
			return [NSNumber numberWithInt:nukeField];
		case 4:
			return [NSNumber numberWithInt:randomClear];
		case 5:
			return [NSNumber numberWithInt:switchField];
		case 6:
			return [NSNumber numberWithInt:clearSpecials];
		case 7:
			return [NSNumber numberWithInt:gravity];
		case 8:
			return [NSNumber numberWithInt:quakeField];
		case 9:
			return [NSNumber numberWithInt:blockBomb];
		default:
			break;
	}
	
	return [NSNumber numberWithInt:invalidSpecial];
}

+ (NSNumber*)numberWithSpecialFromMessageName:(NSString*)specialMessageName
{
	// Check if this is a classic-style add
	if ([specialMessageName rangeOfString:iTetClassicStyleAddSpecialPrefix].location == 0)
		return [NSNumber numberWithInt:(iTetSpecialType)[specialMessageName characterAtIndex:2]];
	
	return [NSNumber numberWithInt:(iTetSpecialType)[specialMessageName characterAtIndex:0]];
}

+ (NSNumber*)numberWithSpecialFromClassicLines:(NSInteger)numLines
{
	switch (numLines)
	{
		case 1:
			return [NSNumber numberWithInt:classicStyle1];
		case 2:
			return [NSNumber numberWithInt:classicStyle2];
		case 4:
			return [NSNumber numberWithInt:classicStyle4];
		default:
			break;
	}
	
	return [NSNumber numberWithInt:invalidSpecial];
}

#pragma mark -
#pragma mark Accessors

- (iTetSpecialType)specialTypeValue
{
	int type = [self intValue];
	switch ((iTetSpecialType)type)
	{
		case addLine:
		case clearLine:
		case nukeField:
		case randomClear:
		case switchField:
		case clearSpecials:
		case gravity:
		case quakeField:
		case blockBomb:
		case classicStyle1:
		case classicStyle2:
		case classicStyle4:
			return (iTetSpecialType)type;
		default:
			break;
	}
	
	return invalidSpecial;
}

- (uint8_t)specialCellValue
{
	int type = [self intValue];
	switch ((iTetSpecialType)type)
	{
		case addLine:
		case clearLine:
		case nukeField:
		case randomClear:
		case switchField:
		case clearSpecials:
		case gravity:
		case quakeField:
		case blockBomb:
			return (uint8_t)type;
		default:
			break;
	}
	
	NSAssert2(NO, @"specialCellValue requested for invalid special type: %c (%d)", type, type);
	
	return 0;
}

- (uint8_t)specialIndexNumber
{
	int type = [self intValue];
	switch ((iTetSpecialType)type)
	{
		case addLine:
			return 1;
		case clearLine:
			return 2;
		case nukeField:
			return 3;
		case randomClear:
			return 4;
		case switchField:
			return 5;
		case clearSpecials:
			return 6;
		case gravity:
			return 7;
		case quakeField:
			return 8;
		case blockBomb:
			return 9;
		default:
			break;
	}
	
	NSAssert2(NO, @"specialIndexNumber requested for invalid special type: %c (%d)", type, type);
	
	return 0;
}

- (NSString*)specialDisplayName
{
	switch ([self specialTypeValue])
	{
		case addLine:
			return iTetAddLineSpecialName;
		case clearLine:
			return iTetClearLineSpecialName;
		case nukeField:
			return iTetNukeFieldSpecialName;
		case randomClear:
			return iTetRandomClearSpecialName;
		case switchField:
			return iTetSwitchFieldSpecialName;
		case clearSpecials:
			return iTetClearSpecialsSpecialName;
		case gravity:
			return iTetGravitySpecialName;
		case quakeField:
			return iTetQuakeFieldSpecialName;
		case blockBomb:
			return iTetBlockBombSpecialName;
		default:
			break;
	}
	
	// No special (or invalid placeholder)
	return iTetInvalidOrNoneSpecialName;
}

- (NSString*)specialMessageName
{
	iTetSpecialType type = [self specialTypeValue];
	switch (type)
	{
		case classicStyle1:
		case classicStyle2:
		case classicStyle4:
			return [NSString stringWithFormat:@"%@%c", iTetClassicStyleAddSpecialPrefix, type];
			
		case addLine:
		case clearLine:
		case nukeField:
		case randomClear:
		case switchField:
		case clearSpecials:
		case gravity:
		case quakeField:
		case blockBomb:
			return [NSString stringWithFormat:@"%c", type];
			
		default:
			break;
	}
	
	NSAssert2(NO, @"specialMessageName requested for invalid special type: %c (%d)", type, type);
	
	return nil;
}

- (BOOL)isClassicStyleAddSpecial
{
	switch ([self specialTypeValue])
	{
		case classicStyle1:
		case classicStyle2:
		case classicStyle4:
			return YES;
		default:
			break;
	}
	
	return NO;
}

- (NSInteger)specialNumberOfClassicLinesValue
{
	switch ([self specialTypeValue])
	{
		case classicStyle1:
			return 1;
		case classicStyle2:
			return 2;
		case classicStyle4:
			return 4;
		default:
			break;
	}
	
	NSAssert2(NO, @"specialNumberOfClassicLinesValue requested for invalid special type: %c (%d)", [self specialTypeValue], [self specialTypeValue]);
	
	return 0;
}

- (BOOL)isPositiveSpecial
{
	switch ([self specialTypeValue])
	{
		case addLine:
		case randomClear:
		case clearSpecials:
		case quakeField:
		case blockBomb:
			return NO;
			
		case clearLine:
		case nukeField:
		case switchField:
		case gravity:
			return YES;
			
		default:
			break;
	}
	
	NSAssert2(NO, @"isPositiveSpecial requested for invalid special type: %c (%d)", [self specialTypeValue], [self specialTypeValue]);
	
	return NO;
}

@end
