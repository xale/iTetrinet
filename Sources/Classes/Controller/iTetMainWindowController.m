//
//  iTetMainWindowController.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMainWindowController.h"

NSString* const iTetMainWindowNibName =	@"MainWindow";

@implementation iTetMainWindowController

- (id)init
{
	if (!(self = [super initWithWindowNibName:iTetMainWindowNibName]))
		return nil;
	
	return self;
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)connectDisconnect:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)showHideChannelsList:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)refreshChannelList:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)beginEndGame:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)forfeitGame:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)pauseResumeGame:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)sendChatMessage:(id)sender
{
	// FIXME: WRITEME
}

- (IBAction)changeTeam:(id)sender
{
	// FIXME: WRITEME
}

@end
