//
//  iTetSpecials.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/8/09.
//

#include "iTetSpecials.h"

NSString* const iTetAddLineSpecialName =		@"Add Line";
NSString* const iTetClearLineSpecialName =		@"Clear Line";
NSString* const iTetNukeFieldSpecialName =		@"Nuke Field";
NSString* const iTetRandomClearSpecialName =	@"Random Clear";
NSString* const iTetSwitchFieldSpecialName =	@"Switch Field";
NSString* const iTetClearSpecialsSpecialName =	@"Clear Specials";
NSString* const iTetGravitySpecialName =		@"Gravity";
NSString* const iTetQuakeFieldSpecialName =		@"Quake Field";
NSString* const iTetBlockBombSpecialName =		@"Block Bomb";
NSString* const iTetInvalidOrNoneSpecialName =	@"No Special";

uint8_t iTetSpecialNumberFromType(iTetSpecialType type)
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
	
	// Not a valid type
	return 0;
}

iTetSpecialType iTetSpecialTypeFromNumber(uint8_t number)
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

NSString* iTetNameForSpecialType(iTetSpecialType type)
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

BOOL iTetSpecialIsPositive(iTetSpecialType type)
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
	
	NSLog(@"WARNING: iTetSpecialIsPositive() called on invalid special type");
	return NO;
}
