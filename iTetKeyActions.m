//
//  iTetKeyActions.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/19/09.
//

#import "iTetKeyActions.h"

#define iTetMovePieceLeftActionName					NSLocalizedStringFromTable(@"Move Piece Left", @"KeyActions", @"Description of action to move the current falling piece to the left")
#define iTetMovePieceRightActionName				NSLocalizedStringFromTable(@"Move Piece Right", @"KeyActions", @"Description of action to move the current falling piece to the right")
#define iTetRotatePieceCounterclockwiseActionName	NSLocalizedStringFromTable(@"Rotate Piece Counterclockwise", @"KeyActions", @"Description of action to rotate the current falling piece counterclockwise")
#define iTetRotatePieceClockwiseActionName			NSLocalizedStringFromTable(@"Rotate Piece Clockwise", @"KeyActions", @"Description of action to rotate the current falling piece clockwise")
#define iTetMovePieceDownActionName					NSLocalizedStringFromTable(@"Move Piece Down", @"KeyActions", @"Description of action to move the current falling piece down by one line")
#define iTetDropPieceActionName						NSLocalizedStringFromTable(@"Drop Piece", @"KeyActions", @"Description of action to drop the current falling piece until it hits another piece or the bottom of the field")
#define iTetDiscardSpecialActionName				NSLocalizedStringFromTable(@"Discard Special", @"KeyActions", @"Description of action to discard (without using) the next special in the specials queue")
#define iTetSelfSpecialActionName					NSLocalizedStringFromTable(@"Use Special on Self", @"KeyActions", @"Description of action to use the next special in the specials queue on yourself")
#define iTetSpecialPlayer1ActionName				NSLocalizedStringFromTable(@"Use Special on Player 1", @"KeyActions", @"Description of action to use the next special in the specials queue on player number 1")
#define iTetSpecialPlayer2ActionName				NSLocalizedStringFromTable(@"Use Special on Player 2", @"KeyActions", @"Description of action to use the next special in the specials queue on player number 2")
#define iTetSpecialPlayer3ActionName				NSLocalizedStringFromTable(@"Use Special on Player 3", @"KeyActions", @"Description of action to use the next special in the specials queue on player number 3")
#define iTetSpecialPlayer4ActionName				NSLocalizedStringFromTable(@"Use Special on Player 4", @"KeyActions", @"Description of action to use the next special in the specials queue on player number 4")
#define iTetSpecialPlayer5ActionName				NSLocalizedStringFromTable(@"Use Special on Player 5", @"KeyActions", @"Description of action to use the next special in the specials queue on player number 5")
#define iTetSpecialPlayer6ActionName				NSLocalizedStringFromTable(@"Use Special on Player 6", @"KeyActions", @"Description of action to use the next special in the specials queue on player number 6")
#define iTetGameChatActionName						NSLocalizedStringFromTable(@"Game Chat", @"KeyActions", @"Description of action that allows the user to start typing a chat message")
#define iTetNoActionName							NSLocalizedStringFromTable(@"No Action", @"KeyActions", @"Placeholder description for unknown or invalid actions")

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
