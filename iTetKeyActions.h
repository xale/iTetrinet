//
//  iTetKeyActions.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/19/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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

extern NSString* const iTetMovePieceLeftActionName;
extern NSString* const iTetMovePieceRightActionName;
extern NSString* const iTetRotatePieceCounterclockwiseActionName;
extern NSString* const iTetRotatePieceClockwiseActionName;
extern NSString* const iTetMovePieceDownActionName;
extern NSString* const iTetDropPieceActionName;
extern NSString* const iTetDiscardSpecialActionName;
extern NSString* const iTetSelfSpecialActionName;
extern NSString* const iTetSpecialPlayer1ActionName;
extern NSString* const iTetSpecialPlayer2ActionName;
extern NSString* const iTetSpecialPlayer3ActionName;
extern NSString* const iTetSpecialPlayer4ActionName;
extern NSString* const iTetSpecialPlayer5ActionName;
extern NSString* const iTetSpecialPlayer6ActionName;
extern NSString* const iTetGameChatActionName;
extern NSString* const iTetNoActionName;

NSString* iTetNameForAction(iTetGameAction action);
