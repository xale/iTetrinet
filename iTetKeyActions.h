//
//  iTetKeyActions.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/19/09.
//
//  NOTE: This file is imported by the NSMutableDictionary Key Bindings category,
//        so any file importing that header needn't import this one

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
	gameChat
} iTetGameAction;

extern NSString* const iTetMovePieceLeftActionName;
extern NSString* const iTetMovePieceRightActionName;
extern NSString* const iTetRotatePieceCounterclockwiseActionName;
extern NSString* const iTetRotatePieceClockwiseActionName;
extern NSString* const iTetMovePieceDownActionName;
extern NSString* const iTetDropPieceActionName;
extern NSString* const iTetGameChatActionName;
extern NSString* const iTetNoActionName;

NSString* iTetNameForAction(iTetGameAction action);
