//
//  iTetKeyActions.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/19/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//
//  NOTE: This file is imported by the iTetKeyBindings header, so any file importing it needn't import this one
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	noAction = 0,
	movePieceLeft,
	movePieceRight,
	rotatePieceCounterclockwise,
	rotatePieceClockwise,
	movePieceDown,
	dropPiece,
	discardSpecial,
	selfSpecial,
	specialPlayer1,
	specialPlayer2,
	specialPlayer3,
	specialPlayer4,
	specialPlayer5,
	specialPlayer6,
	gameChat
} iTetGameAction;

NSString* iTetNameForAction(iTetGameAction action);
