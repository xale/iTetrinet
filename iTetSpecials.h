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

@interface iTetSpecials : NSObject

+ (iTetSpecialType)specialTypeForNumber:(uint8_t)number;
+ (uint8_t)numberForSpecialType:(iTetSpecialType)type;

+ (iTetSpecialType)specialTypeFromMessageName:(NSString*)name;
+ (NSString*)messageNameForSpecialType:(iTetSpecialType)type;

+ (NSString*)nameForSpecialType:(iTetSpecialType)type;

+ (BOOL)specialIsPositive:(iTetSpecialType)type;

@end
