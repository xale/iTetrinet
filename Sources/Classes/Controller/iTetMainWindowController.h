//
//  iTetMainWindowController.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface iTetMainWindowController : NSWindowController
{
	
}

- (IBAction)connectDisconnect:(id)sender;

- (IBAction)showHideChannelsList:(id)sender;
- (IBAction)refreshChannelList:(id)sender;

- (IBAction)beginEndGame:(id)sender;
- (IBAction)forfeitGame:(id)sender;
- (IBAction)pauseResumeGame:(id)sender;

- (IBAction)sendChatMessage:(id)sender;
- (IBAction)changeTeam:(id)sender;

@end
