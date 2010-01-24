//
//  iTetKeyActions.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/19/09.
//

#import "iTetKeyActions.h"

NSString* const iTetMovePieceLeftActionName =			@"Move Piece Left";
NSString* const iTetMovePieceRightActionName =			@"Move Piece Right";
NSString* const iTetRotatePieceCounterclockwiseActionName =	@"Rotate Piece Counterclockwise";
NSString* const iTetRotatePieceClockwiseActionName =		@"Rotate Piece Clockwise";
NSString* const iTetMovePieceDownActionName =			@"Move Piece Down";
NSString* const iTetDropPieceActionName =				@"Drop Piece";
NSString* const iTetDiscardSpecialActionName =			@"Discard Special";
NSString* const iTetSelfSpecialActionName =			@"Use Special on Self";
NSString* const iTetGameChatActionName =				@"Game Chat";
NSString* const iTetNoActionName =					@"No Action";

NSString* iTetNameForAction(iTetGameAction action)
{
	switch (action)
	{
		case movePieceLeft:
			return iTetMovePieceLeftActionName;
			
		case movePieceRight:
			return iTetMovePieceRightActionName;
			
		case rotatePieceCounterclockwise:
			return iTetRotatePieceCounterclockwiseActionName;
			
		case rotatePieceClockwise:
			return iTetRotatePieceClockwiseActionName;
			
		case movePieceDown:
			return iTetMovePieceDownActionName;
			
		case dropPiece:
			return iTetDropPieceActionName;
			
		case discardSpecial:
			return iTetDiscardSpecialActionName;
			
		case selfSpecial:
			return iTetSelfSpecialActionName;
			
		case gameChat:
			return iTetGameChatActionName;
	}
	
	return iTetNoActionName;
}
