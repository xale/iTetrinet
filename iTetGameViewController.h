//
//  iTetGameViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetSpecials.h"

@class iTetAppController;
@class iTetFieldView;
@class iTetLocalFieldView;
@class iTetNextBlockView;
@class iTetSpecialsView;
@class iTetPlayer;
@class iTetGameRules;
@class iTetBlock;
@class iTetKeyNamePair;
@class Queue;

@interface iTetGameViewController : NSObject
{
	IBOutlet iTetAppController* appController;
	
	// Local player's views
	IBOutlet iTetLocalFieldView* localFieldView;
	IBOutlet iTetNextBlockView* nextBlockView;
	IBOutlet iTetSpecialsView* specialsView;
	
	// Remote players' views
	IBOutlet iTetFieldView* remoteFieldView1;
	IBOutlet iTetFieldView* remoteFieldView2;
	IBOutlet iTetFieldView* remoteFieldView3;
	IBOutlet iTetFieldView* remoteFieldView4;
	IBOutlet iTetFieldView* remoteFieldView5;
	
	// Chat views
	IBOutlet NSTextView* chatView;
	IBOutlet NSTextField* messageField;
	
	// Action history view
	IBOutlet NSTableView* actionListView;
	
	// Rules for game in progress (nil indicates no game in progress)
	iTetGameRules* currentGameRules;
	
	// Local player's current falling block, next block and specials queue
	iTetBlock* currentBlock;
	iTetBlock* nextBlock;
	Queue* specialsQueue;
	
	// Pause/play state of current game
	BOOL gamePaused;
	
	// List of player actions (e.g., specials)
	NSMutableArray* actionHistory;
}

- (IBAction)sendMessage:(id)sender;

- (void)newGameWithPlayers:(NSArray*)players
			   rules:(iTetGameRules*)rules;
- (void)endGame;

- (void)solidifyCurrentBlock;
- (void)moveNextBlockToField;

- (void)sendFieldstring;
- (void)sendPartialFieldstring;

- (void)specialUsed:(iTetSpecialType)special
	     byPlayer:(iTetPlayer*)sender
	     onPlayer:(iTetPlayer*)target;
- (void)linesAdded:(int)numLines
	    byPlayer:(iTetPlayer*)sender;
- (void)recordAction:(NSString*)description;
- (void)clearActions;

- (void)keyPressed:(iTetKeyNamePair*)key
  onLocalFieldView:(iTetLocalFieldView*)fieldView;

@property (readwrite, retain) iTetBlock* currentBlock;
@property (readwrite, retain) iTetBlock* nextBlock;
@property (readwrite, retain) Queue* specialsQueue;

@property (readonly) BOOL gameInProgress;
@property (readwrite) BOOL gamePaused;

@end
