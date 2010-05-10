//
//  iTetSpecials.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import <Cocoa/Cocoa.h>

#define ITET_NUM_SPECIAL_TYPES 9
typedef enum
{
	addLine =		'a',
	clearLine =		'c',
	nukeField =		'n',
	randomClear =	'r',
	switchField =	's',
	clearSpecials =	'b',
	gravity =		'g',
	quakeField =	'q',
	blockBomb =		'o',
	
	classicStyle1 =	'1',
	classicStyle2 =	'2',
	classicStyle4 =	'4',
	
	invalidSpecial = 0
} iTetSpecialType;

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

@interface iTetSpecials : NSObject

+ (iTetSpecialType)specialTypeForNumber:(uint8_t)number;
+ (uint8_t)numberForSpecialType:(iTetSpecialType)type;

+ (iTetSpecialType)specialTypeFromMessageName:(NSString*)name;
+ (NSString*)messageNameForSpecialType:(iTetSpecialType)type;

+ (iTetSpecialType)specialTypeForClassicLines:(NSInteger)lines;
+ (NSInteger)classicLinesForSpecialType:(iTetSpecialType)type;

+ (NSString*)nameForSpecialType:(iTetSpecialType)type;

+ (BOOL)specialIsPositive:(iTetSpecialType)type;

@end
