//
//  iTetGameViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import "iTetGameViewController.h"
#import "iTetAppController.h"
#import "iTetPlayer.h"

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
	// FIXME: WRITEME
}

- (void)removeBoardAssignmentForPlayer:(iTetPlayer*)player
{
	// FIXME: WRITEME
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
