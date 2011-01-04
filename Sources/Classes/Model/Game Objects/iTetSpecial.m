//
//  iTetSpecial.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/16/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetSpecial.h"

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

@implementation iTetSpecial

+ (id)specialWithType:(iTetSpecialType)specialType
{
	return [[[self alloc] initWithType:specialType] autorelease];
}

- (id)initWithType:(iTetSpecialType)specialType
{
	type = specialType;
	
	return self;
}

+ (id)specialFromCellValue:(uint8_t)specialCellValue
{
	switch (specialCellValue)
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
			return [self specialWithType:specialCellValue];
		default:
			break;
	}
	
	return [self specialWithType:invalidSpecial];
}

+ (id)specialFromIndexNumber:(uint8_t)specialIndexNumber
{
	switch (specialIndexNumber)
	{
		case 1:
			return [self specialWithType:addLine];
		case 2:
			return [self specialWithType:clearLine];
		case 3:
			return [self specialWithType:nukeField];
		case 4:
			return [self specialWithType:randomClear];
		case 5:
			return [self specialWithType:switchField];
		case 6:
			return [self specialWithType:clearSpecials];
		case 7:
			return [self specialWithType:gravity];
		case 8:
			return [self specialWithType:quakeField];
		case 9:
			return [self specialWithType:blockBomb];
		default:
			break;
	}
	
	return [self specialWithType:invalidSpecial];
}

+ (id)specialFromMessageName:(NSString*)specialMessageName
{
	// Check if this is a classic-style add
	if ([specialMessageName rangeOfString:iTetClassicStyleAddSpecialPrefix].location == 0)
		return [self specialWithType:[specialMessageName characterAtIndex:2]];
	
	return [self specialWithType:[specialMessageName characterAtIndex:0]];
}

+ (id)specialFromClassicLines:(NSInteger)numLines
{
	switch (numLines)
	{
		case 1:
			return [self specialWithType:classicStyle1];
		case 2:
			return [self specialWithType:classicStyle2];
		case 4:
			return [self specialWithType:classicStyle4];
		default:
			break;
	}
	
	return [self specialWithType:invalidSpecial];
}

#pragma mark -
#pragma mark Accessors

@synthesize type;

- (uint8_t)cellValue
{
	switch (type)
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
	
	NSString* excDesc = [NSString stringWithFormat:@"cellValue requested for invalid special type: %@ (%d)", [self displayName], type];
	NSException* invalidSpecialException = [NSException exceptionWithName:@"iTetInvalidSpecialTypeException"
																   reason:excDesc
																 userInfo:nil];
	@throw invalidSpecialException;
}

- (uint8_t)indexNumber
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
	
	NSString* excDesc = [NSString stringWithFormat:@"indexNumber requested for invalid special type: %@ (%d)", [self displayName], type];
	NSException* invalidSpecialException = [NSException exceptionWithName:@"iTetInvalidSpecialTypeException"
																   reason:excDesc
																 userInfo:nil];
	@throw invalidSpecialException;
}

- (NSString*)displayName
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

- (NSString*)messageName
{
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
	
	NSString* excDesc = [NSString stringWithFormat:@"messageName requested for invalid special type: %@ (%d)", [self displayName], type];
	NSException* invalidSpecialException = [NSException exceptionWithName:@"iTetInvalidSpecialTypeException"
																   reason:excDesc
																 userInfo:nil];
	@throw invalidSpecialException;
}

- (BOOL)isClassicStyleAdd
{
	switch (type)
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

- (NSInteger)numberOfClassicLines
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
	
	NSString* excDesc = [NSString stringWithFormat:@"numberOfClassicLines requested for invalid special type: %@ (%d)", [self displayName], type];
	NSException* invalidSpecialException = [NSException exceptionWithName:@"iTetInvalidSpecialTypeException"
																   reason:excDesc
																 userInfo:nil];
	@throw invalidSpecialException;
}

- (BOOL)hasPositiveEffect
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
	
	NSString* excDesc = [NSString stringWithFormat:@"hasPositiveEffect requested for invalid special type: %@ (%d)", [self displayName], type];
	NSException* invalidSpecialException = [NSException exceptionWithName:@"iTetInvalidSpecialTypeException"
																   reason:excDesc
																 userInfo:nil];
	@throw invalidSpecialException;
}

@end
