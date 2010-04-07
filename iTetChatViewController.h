//
//  iTetChatViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/16/09.
//

#import <Cocoa/Cocoa.h>

@class iTetWindowController;
@class iTetPlayersController;
@class iTetNetworkController;

@class iTetPlayer;

@interface iTetChatViewController : NSObject
{
	// Top-level controllers
	IBOutlet iTetWindowController* windowController;
	IBOutlet iTetPlayersController* playersController;
	IBOutlet iTetNetworkController* networkController;
	
	// Chat views
	IBOutlet NSTextView* chatView;
	IBOutlet NSTextField* messageField;
	
	// Channels array
	NSMutableArray* channels;
}

- (IBAction)submitChatMessage:(id)sender;

- (void)clearChat;
- (void)appendChatLine:(NSAttributedString*)line;
- (void)appendChatLine:(NSAttributedString*)line
			fromPlayer:(iTetPlayer*)player
				action:(BOOL)isAction;
- (void)appendStatusMessage:(NSString*)message;

// - (void)addChannel:(NSString*)channelData;

@property (readonly) NSArray* channels;

@end
