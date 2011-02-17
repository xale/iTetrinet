//
//  iTetServerBrowserWindowController.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/11.
//  Copyright 2011 Indie Pennant Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iTetServerBrowserWindowController : NSWindowController <NSUserInterfaceValidations>
{
	IBOutlet NSArrayController* internetServersController;
	IBOutlet NSArrayController* favoriteServersController;
	BOOL refreshingServerList;
	
	IBOutlet NSTabView* browserTabView;
	
	IBOutlet NSPopUpButton* gameTypeMenu;
	IBOutlet NSPopUpButton* protocolMenu;
	IBOutlet NSTextField* nicknameField;
	IBOutlet NSTextField* teamNameField;
	IBOutlet NSTextField* spectatorPasswordField;
	
	IBOutlet NSProgressIndicator* networkProgressIndicator;
	IBOutlet NSTextField* networkStatusLabel;
}

- (IBAction)connect:(id)sender;
- (IBAction)refreshServerList:(id)sender;
- (IBAction)addNewServerToFavorites:(id)sender;
- (IBAction)addSelectedServersToFavorites:(id)sender;

@property (readwrite, assign, getter=isRefreshingServerList) BOOL refreshingServerList;

@end
