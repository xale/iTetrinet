//
//  iTetChatViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/16/09.
//

#import <Cocoa/Cocoa.h>

@class iTetAppController;

@interface iTetChatViewController : NSObject
{
	IBOutlet iTetAppController* appController;
	
	// Chat views
	IBOutlet NSTextView* chatView;
	IBOutlet NSTextField* messageField;
	
	// Channels array
	NSMutableArray* channels;
}

- (IBAction)sendMessage:(id)sender;

- (void)clearChat;
- (void)appendChatLine:(NSString*)line;
- (void)appendChatLine:(NSString*)line
	  fromPlayerName:(NSString*)playerName
		    action:(BOOL)isAction;

- (void)addChannel:(NSString*)channelData;

@property (readonly) NSArray* channels;

@end
