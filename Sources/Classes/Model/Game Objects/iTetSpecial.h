//
//  iTetSpecial.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/16/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
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

@interface iTetSpecial : NSObject
{
	iTetSpecialType type;
}

+ (id)specialWithType:(iTetSpecialType)specialType;
- (id)initWithType:(iTetSpecialType)specialType;

+ (id)specialFromCellValue:(uint8_t)specialCellValue;

+ (id)specialFromIndexNumber:(uint8_t)specialIndexNumber;

+ (id)specialFromMessageName:(NSString*)specialMessageName;

+ (id)specialFromClassicLines:(NSInteger)numLines;

@property (readonly) iTetSpecialType type;
@property (readonly) uint8_t cellValue;
@property (readonly) uint8_t indexNumber;
@property (readonly) NSString* displayName;
@property (readonly) NSString* messageName;
@property (readonly) BOOL isClassicStyleAdd;
@property (readonly) NSInteger numberOfClassicLines;
@property (readonly) BOOL hasPositiveEffect;

@end
