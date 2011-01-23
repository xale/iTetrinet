//
//  iTetChatViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/16/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetPlayersController;
@class iTetNetworkController;

@class iTetPlayer;

@interface iTetChatViewController : NSObject <NSUserInterfaceValidations>
{
	// Top-level controllers
	IBOutlet iTetPlayersController* playersController;
	IBOutlet iTetNetworkController* networkController;
	
	// Chat views
	IBOutlet NSTextView* chatView;
	IBOutlet NSTextField* messageField;
}

- (IBAction)submitChatMessage:(id)sender;
- (IBAction)changeTextColor:(id)sender;

- (void)clearChat;
- (void)appendChatLine:(NSAttributedString*)line;
- (void)appendChatLine:(NSAttributedString*)line
			fromPlayer:(iTetPlayer*)player
				action:(BOOL)isAction;
- (void)appendStatusMessage:(NSString*)message;

@end
