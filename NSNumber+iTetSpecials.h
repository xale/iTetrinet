//
//  NSNumber+iTetSpecials.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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

@interface NSNumber (iTetSpecials)

+ (NSNumber*)numberWithSpecialType:(iTetSpecialType)specialType;
+ (NSNumber*)numberWithSpecialFromCellValue:(uint8_t)specialCellValue;
+ (NSNumber*)numberWithSpecialAtIndexNumber:(uint8_t)specialNumber;
+ (NSNumber*)numberWithSpecialFromMessageName:(NSString*)specialMessageName;
+ (NSNumber*)numberWithSpecialFromClassicLines:(NSInteger)numLines;

- (iTetSpecialType)specialTypeValue;
- (uint8_t)specialCellValue;
- (uint8_t)specialIndexNumber;
- (NSString*)specialDisplayName;
- (NSString*)specialMessageName;
- (BOOL)isClassicStyleAddSpecial;
- (NSInteger)specialNumberOfClassicLinesValue;
- (BOOL)isPositiveSpecial;

@end
