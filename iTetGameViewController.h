//
//  iTetGameViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import <Cocoa/Cocoa.h>

@class iTetAppController;
@class iTetBoardView;
@class iTetLocalBoardView;
@class iTetPlayer;

@interface iTetGameViewController : NSObject
{
	IBOutlet iTetAppController* appController;
	
	// Interface objects
	IBOutlet iTetLocalBoardView* localBoardView;
	IBOutlet iTetBoardView* board1;
	IBOutlet iTetBoardView* board2;
	IBOutlet iTetBoardView* board3;
	IBOutlet iTetBoardView* board4;
	IBOutlet iTetBoardView* board5;
	IBOutlet NSTextView* chatView;
	IBOutlet NSTextField* messageField;
	
	char occupiedBoardViews;
}

- (IBAction)sendMessage:(id)sender;

- (void)assignBoardToPlayer:(iTetPlayer*)player;
- (void)removeBoardAssignmentForPlayer:(iTetPlayer*)player;

@end
