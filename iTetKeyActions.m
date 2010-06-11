//
//  iTetKeyActions.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/19/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetKeyActions.h"

NSString* const iTetMovePieceLeftActionName =				@"Move Piece Left";
NSString* const iTetMovePieceRightActionName =				@"Move Piece Right";
NSString* const iTetRotatePieceCounterclockwiseActionName =	@"Rotate Piece Counterclockwise";
NSString* const iTetRotatePieceClockwiseActionName =		@"Rotate Piece Clockwise";
NSString* const iTetMovePieceDownActionName =				@"Move Piece Down";
NSString* const iTetDropPieceActionName =					@"Drop Piece";
NSString* const iTetDiscardSpecialActionName =				@"Discard Special";
NSString* const iTetSelfSpecialActionName =					@"Use Special on Self";
NSString* const iTetSpecialPlayer1ActionName =				@"Use Special on Player 1";
NSString* const iTetSpecialPlayer2ActionName =				@"Use Special on Player 2";
NSString* const iTetSpecialPlayer3ActionName =				@"Use Special on Player 3";
NSString* const iTetSpecialPlayer4ActionName =				@"Use Special on Player 4";
NSString* const iTetSpecialPlayer5ActionName =				@"Use Special on Player 5";
NSString* const iTetSpecialPlayer6ActionName =				@"Use Special on Player 6";
NSString* const iTetGameChatActionName =					@"Game Chat";
NSString* const iTetNoActionName =							@"No Action";

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
			
		case specialPlayer1:
			return iTetSpecialPlayer1ActionName;
			
		case specialPlayer2:
			return iTetSpecialPlayer2ActionName;
			
		case specialPlayer3:
			return iTetSpecialPlayer3ActionName;
			
		case specialPlayer4:
			return iTetSpecialPlayer4ActionName;
			
		case specialPlayer5:
			return iTetSpecialPlayer5ActionName;
			
		case specialPlayer6:
			return iTetSpecialPlayer6ActionName;
			
		case gameChat:
			return iTetGameChatActionName;
			
		default:
			break;
	}
	
	return iTetNoActionName;
}
