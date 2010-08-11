//
//  iTetSpecials.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/8/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#include "iTetSpecials.h"

@implementation iTetSpecials

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

+ (uint8_t)numberForSpecialType:(iTetSpecialType)type
{
	switch (type)
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
	
	// Classic-style add or invalid type
	return 0;
}

+ (iTetSpecialType)specialTypeForNumber:(uint8_t)number
{
	switch (number)
	{
		case 1:
			return addLine;
		case 2:
			return clearLine;
		case 3:
			return nukeField;
		case 4:
			return randomClear;
		case 5:
			return switchField;
		case 6:
			return clearSpecials;
		case 7:
			return gravity;
		case 8:
			return quakeField;
		case 9:
			return blockBomb;
	}
	
	// Not a valid type
	return invalidSpecial;
}

NSString* const iTetClassicStyleAddSpecialPrefix = @"cs";

+ (iTetSpecialType)specialTypeFromMessageName:(NSString*)name
{
	// Check if this is a classic-style add
	if ([name rangeOfString:iTetClassicStyleAddSpecialPrefix].location == 0)
		return (iTetSpecialType)[name characterAtIndex:2];
	
	return (iTetSpecialType)[name characterAtIndex:0];
}

+ (NSString*)messageNameForSpecialType:(iTetSpecialType)type
{
	switch (type)
	{
		case classicStyle1:
		case classicStyle2:
		case classicStyle4:
			return [NSString stringWithFormat:@"%@%c", iTetClassicStyleAddSpecialPrefix, (uint8_t)type];
			
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
	
	NSAssert2(NO, @"invalid special type in messageNameForSpecialType: %c (%d)", type, type);
	
	return nil;
}

+ (NSString*)nameForSpecialType:(iTetSpecialType)type
{
	switch (type)
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

+ (iTetSpecialType)specialTypeForClassicLines:(NSInteger)lines
{
	switch (lines)
	{
		case 1:
			return classicStyle1;
		case 2:
			return classicStyle2;
		case 4:
			return classicStyle4;
		default:
			break;
	}
	
	return invalidSpecial;
}

+ (NSInteger)classicLinesForSpecialType:(iTetSpecialType)type
{
	switch (type)
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
	
	return 0;
}

+ (BOOL)specialIsPositive:(iTetSpecialType)type
{
	switch (type)
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
	
	NSAssert2(NO, @"iTetSpecials +specialIsPositive: called on invalid special type: %c (%d)", type, type);
	return NO;
}

@end
