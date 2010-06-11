//
//  iTetKeyView.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/16/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetKeyActions.h"

@class iTetKeyNamePair;

@interface iTetKeyView : NSView
{
	iTetGameAction associatedAction;
	NSImage* currentKeyImage;
	BOOL highlighted;
	
	IBOutlet id delegate;
	IBOutlet NSTextField* actionNameField;
}

- (void)setRepresentedKey:(iTetKeyNamePair*)keyName;

@property (readwrite, assign) iTetGameAction associatedAction;
@property (readwrite, retain) NSImage* currentKeyImage;
@property (readwrite, assign) BOOL highlighted;

@end

@interface NSObject (iTetKeyViewDelegate)

- (BOOL)		keyView:(iTetKeyView*)keyView
shouldSetRepresentedKey:(iTetKeyNamePair*)key;
- (void)	 keyView:(iTetKeyView*)keyView
didSetRepresentedKey:(iTetKeyNamePair*)key;

@end
