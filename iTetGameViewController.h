//
//  iTetGameViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetSpecials.h"
#import "iTetGameplayState.h"

@class iTetWindowController;
@class iTetPlayersController;
@class iTetNetworkController;
@class iTetFieldView;
@class iTetLocalFieldView;
@class iTetNextBlockView;
@class iTetSpecialsView;
@class IPSScalableLevelIndicator;
@class iTetPlayer;
@class iTetServerInfo;
@class iTetGameRules;
@class iTetKeyNamePair;

typedef enum
{
	nextBlock,
	blockFall
} iTetBlockTimerType;

@interface iTetGameViewController : NSObject <NSUserInterfaceValidations>
{
	// Top-level controllers
	IBOutlet iTetWindowController* windowController;
	IBOutlet iTetPlayersController* playersController;
	IBOutlet iTetNetworkController* networkController;
	
	// Menu and toolbar items
	IBOutlet NSToolbarItem* gameButton;
	IBOutlet NSMenuItem* gameMenuItem;
	IBOutlet NSToolbarItem* pauseButton;
	IBOutlet NSMenuItem* pauseMenuItem;
	
	// Local player's views
	IBOutlet iTetLocalFieldView* localFieldView;
	IBOutlet iTetNextBlockView* nextBlockView;
	IBOutlet iTetSpecialsView* specialsView;
	IBOutlet IPSScalableLevelIndicator* levelProgressIndicator;
	IBOutlet IPSScalableLevelIndicator* specialsProgressIndicator;
	
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
	IBOutlet NSTextView* actionListView;
	
	// Rules for game in progress
	iTetGameRules* currentGameRules;
	
	// Timer for local player's falling block
	NSTimer* blockTimer;
	
	// State of current game
	iTetGameplayState gameplayState;
	
	// Current key bindings
	NSDictionary* keyConfiguration;
	
	// Data stored when game is paused
	NSTimeInterval timeUntilNextTimerFire;
	iTetBlockTimerType lastTimerType;
}

- (IBAction)submitChatMessage:(id)sender;
- (IBAction)startStopGame:(id)sender;
- (IBAction)forfeitGame:(id)sender;
- (IBAction)pauseResumeGame:(id)sender;

- (void)appendChatLine:(NSString*)line
		fromPlayerName:(NSString*)playerName;
- (void)appendChatLine:(NSString*)line;
- (void)clearChat;

- (void)newGameWithPlayers:(NSArray*)players
				 rulesList:(NSArray*)rulesArray
				  onServer:(iTetServerInfo*)gameServer;
- (void)pauseGame;
- (void)resumeGame;
- (void)endGame;

- (void)sendFieldstring;
- (void)sendPartialFieldstring;
- (void)sendCurrentLevel;
- (void)sendSpecial:(iTetSpecialType)special
		   toPlayer:(iTetPlayer*)target;
- (void)sendLines:(NSInteger)lines;

- (void)fieldstringReceived:(NSString*)fieldstring
				  forPlayer:(iTetPlayer*)player
			  partialUpdate:(BOOL)isPartial;
- (void)specialUsed:(iTetSpecialType)special
		   byPlayer:(iTetPlayer*)sender
		   onPlayer:(iTetPlayer*)target;

@property (readwrite, retain) iTetGameRules* currentGameRules;
@property (readwrite, assign) iTetGameplayState gameplayState;
@property (readonly) BOOL gameInProgress;

@end
