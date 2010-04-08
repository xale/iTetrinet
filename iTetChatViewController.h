//
//  iTetChatViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/16/09.
//

#import <Cocoa/Cocoa.h>

@class iTetPlayersController;
@class iTetNetworkController;

@class iTetPlayer;

@interface iTetChatViewController : NSObject
{
	// Top-level controllers
	IBOutlet iTetPlayersController* playersController;
	IBOutlet iTetNetworkController* networkController;
	
	// Chat views
	IBOutlet NSTextView* chatView;
	IBOutlet NSTextField* messageField;
}

- (IBAction)submitChatMessage:(id)sender;

- (void)clearChat;
- (void)appendChatLine:(NSAttributedString*)line;
- (void)appendChatLine:(NSAttributedString*)line
			fromPlayer:(iTetPlayer*)player
				action:(BOOL)isAction;
- (void)appendStatusMessage:(NSString*)message;

@end
