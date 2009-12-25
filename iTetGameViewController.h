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

@interface iTetGameViewController : NSObject
{
	IBOutlet iTetAppController* appController;
	
	// Interface objects
	// Local player's views
	IBOutlet iTetLocalFieldView* localFieldView;
	IBOutlet iTetNextBlockView* nextBlockView;
	IBOutlet iTetSpecialsView* specialsView;
	
	// Remote players' field views
	IBOutlet iTetFieldView* field1;
	IBOutlet iTetFieldView* field2;
	IBOutlet iTetFieldView* field3;
	IBOutlet iTetFieldView* field4;
	IBOutlet iTetFieldView* field5;
	NSArray* fieldViews;
	
	// Chat views
	IBOutlet NSTextView* chatView;
	IBOutlet NSTextField* messageField;
	
	// Action history view
	IBOutlet NSTableView* actionListView;
	
	// Rules for game in progress (nil indicates no game in progress)
	iTetGameRules* currentGameRules;
	
	// Pause/play state of current game
	BOOL gamePaused;
	
	// List of player actions (e.g., specials)
	NSMutableArray* actionHistory;
}

- (IBAction)sendMessage:(id)sender;

- (void)assignFieldViewToPlayer:(iTetPlayer*)player;
- (void)removeFieldViewAssignmentForPlayer:(iTetPlayer*)player;

- (void)newGameWithPlayers:(NSArray*)players
			   rules:(iTetGameRules*)rules;
- (void)endGame;

- (void)sendFieldstring;
- (void)sendPartialFieldstring;

- (void)specialUsed:(iTetSpecialType)special
	     byPlayer:(iTetPlayer*)sender
	     onPlayer:(iTetPlayer*)target;
- (void)linesAdded:(int)numLines
	    byPlayer:(iTetPlayer*)sender;
- (void)recordAction:(NSString*)description;
- (void)clearActions;

@property (readonly) BOOL gameInProgress;
@property (readwrite) BOOL gamePaused;

@end
