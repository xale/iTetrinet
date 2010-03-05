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
	invalidSpecial = 0
} iTetSpecialType;

extern NSString* const iTetAddLineSpecialName;
extern NSString* const iTetClearLineSpecialName;
extern NSString* const iTetNukeFieldSpecialName;
extern NSString* const iTetRandomClearSpecialName;
extern NSString* const iTetSwitchFieldSpecialName;
extern NSString* const iTetClearSpecialsSpecialName;
extern NSString* const iTetGravitySpecialName;
extern NSString* const iTetQuakeFieldSpecialName;
extern NSString* const iTetBlockBombSpecialName;
extern NSString* const iTetInvalidOrNoneSpecialName;

uint8_t iTetSpecialNumberFromType(iTetSpecialType type);
iTetSpecialType iTetSpecialTypeFromNumber(uint8_t number);
NSString* iTetNameForSpecialType(iTetSpecialType type);
BOOL iTetSpecialIsPositive(iTetSpecialType type);
