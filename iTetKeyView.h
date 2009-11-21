//
//  iTetKeyView.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/16/09.
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

- (NSImage*)keyImageWithString:(NSString*)keyName;

- (void)keyPressed:(iTetKeyNamePair*)key;

- (void)setRepresentedKey:(iTetKeyNamePair*)keyName;
@property (readwrite, assign) iTetGameAction associatedAction;
@property (readwrite, retain) NSImage* currentKeyImage;
@property (readwrite, assign) BOOL highlighted;

@end
