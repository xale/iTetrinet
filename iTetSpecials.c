//
//  iTetSpecials.c
//  iTetrinet
//
//  Created by Alex Heinz on 10/8/09.
//

#include "iTetSpecials.h"

char iTetSpecialNumberFromType(iTetSpecialType type)
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
	}
	
	// Not a valid type
	return 0;
}

iTetSpecialType iTetSpecialTypeFromNumber(char number)
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
