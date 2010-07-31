//
//  iTetGameViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/7/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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
@class iTetRandomBlockGenerator;
@class iTetKeyConfiguration;

typedef enum
{
	nextBlockTimer,
	blockFallTimer
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
	NSDictionary* currentGameRules;
	
	// Random block generator
	iTetRandomBlockGenerator* blockGenerator;
	
	// Timer for local player's falling block
	NSTimer* blockTimer;
	
	// State of current game
	iTetGameplayState gameplayState;
	
	// Current key bindings
	iTetKeyConfiguration* currentKeyConfiguration;
	
	// Data stored when game is paused
	NSTimeInterval timeUntilNextTimerFire;
	iTetBlockTimerType lastTimerType;
}

- (IBAction)startStopGame:(id)sender;
- (IBAction)forfeitGame:(id)sender;
- (IBAction)pauseResumeGame:(id)sender;
- (IBAction)submitChatMessage:(id)sender;

- (void)chatMessageReceived:(NSString*)messageContents;
- (void)clearChat;

- (void)newGameWithPlayers:(NSArray*)players
					 rules:(NSDictionary*)rules;
- (void)pauseGame;
- (void)resumeGame;
- (void)endGame;

- (void)fieldstringReceived:(NSString*)fieldstring
				  forPlayer:(iTetPlayer*)player;
- (void)specialUsed:(iTetSpecialType)special
		   byPlayer:(iTetPlayer*)sender
		   onPlayer:(iTetPlayer*)target;

@property (readwrite, retain) NSDictionary* currentGameRules;
@property (readwrite, assign) iTetGameplayState gameplayState;
@property (readonly) BOOL gameInProgress;

@end
