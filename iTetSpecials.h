//
//  iTetSpecials.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#define ITET_NUM_SPECIAL_TYPES 9
typedef enum
{
	addLine = 'a',
	clearLine = 'c',
	nukeField = 'n',
	randomClear = 'r',
	switchField = 's',
	clearSpecials = 'b',
	gravity = 'g',
	quakeField = 'q',
	blockBomb = 'o',
	invalidSpecial = 0
} iTetSpecialType;

char iTetSpecialNumberFromType(iTetSpecialType type);
iTetSpecialType iTetSpecialTypeFromNumber(char number);