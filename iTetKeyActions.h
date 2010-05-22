//
//  iTetKeyActions.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/19/09.
//
//  NOTE: This file is imported by the NSMutableDictionary Key Bindings category, so any file importing that header needn't import this one
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
