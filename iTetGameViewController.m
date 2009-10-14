//
//  iTetGameViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import "iTetGameViewController.h"
#import "iTetAppController.h"
#import "iTetLocalPlayer.h"
#import "iTetLocalBoardView.h"

#define BOARD_1	0x01
#define BOARD_2	0x02
#define BOARD_3	0x04
#define BOARD_4	0x08
#define BOARD_5	0x10

@implementation iTetGameViewController

#pragma mark -
#pragma mark Interface Actions

- (IBAction)sendMessage:(id)sender
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Player-Board Assignment

- (void)assignBoardToPlayer:(iTetPlayer*)player
{
	// Generate a random board for the player
	[player setBoard:[iTetBoard boardWithRandomContents]];
	
	// Find an un-assigned board, and assign it to the player
	if ((assignedBoards & BOARD_1) == 0)
	{
		[board1 setOwner:player];
		assignedBoards += BOARD_1;
	}
	else if ((assignedBoards & BOARD_2) == 0)
	{
		[board2 setOwner:player];
		assignedBoards += BOARD_2;
	}
	else if ((assignedBoards & BOARD_3) == 0)
	{
		[board3 setOwner:player];
		assignedBoards += BOARD_3;
	}
	else if ((assignedBoards & BOARD_4) == 0)
	{
		[board4 setOwner:player];
		assignedBoards += BOARD_4;
	}
	else if ((assignedBoards & BOARD_5) == 0)
	{
		[board5 setOwner:player];
		assignedBoards += BOARD_5;
	}
	else
	{
		// No available boards (shouldn't happen)
		NSLog(@"Warning: iTetGameController -assignBoardToPlayer: called with no available boards");
	}
}

- (void)removeBoardAssignmentForPlayer:(iTetPlayer*)player
{
	// Find the board belonging to this player
	int playerNum = [player playerNumber];
	if ([[board1 owner] playerNumber] == playerNum)
	{
		[board1 setOwner:nil];
		assignedBoards -= BOARD_1;
	}
	else if ([[board2 owner] playerNumber] == playerNum)
	{
		[board2 setOwner:nil];
		assignedBoards -= BOARD_2;
	}
	else if ([[board3 owner] playerNumber] == playerNum)
	{
		[board3 setOwner:nil];
		assignedBoards -= BOARD_3;
	}
	else if ([[board4 owner] playerNumber] == playerNum)
	{
		[board4 setOwner:nil];
		assignedBoards -= BOARD_4;
	}
	else if ([[board5 owner] playerNumber] == playerNum)
	{
		[board5 setOwner:nil];
		assignedBoards -= BOARD_5;
	}
	else
	{
		// Player is not assigned to a board (shouldn't happen)
		NSLog(@"Warning: iTetGameController -removeBoardAssignmentForPlayer: called with player not assigned to a board");
	}
}

#pragma mark -
#pragma mark Starting a Game

- (void)newGameWithStartingLevel:(int)startLevel
		  initialStackHeight:(int)stackHeight
				   rules:(iTetGameRules*)rules
{
	// FIXME: WRITEME
}

#pragma mark -
#pragma mark Accessors

- (BOOL)gameInProgress
{
	// FIXME: WRITEME
	return NO;
}

@end
