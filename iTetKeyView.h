//
//  iTetKeyView.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/16/09.
//

#import <Cocoa/Cocoa.h>

@class iTetKeyNamePair;

@interface iTetKeyView : NSView
{	
	NSImage* currentKeyImage;
	BOOL highlighted;
	
	IBOutlet id delegate;
	IBOutlet NSTextField* actionNameField;
}

- (NSImage*)keyImageWithString:(NSString*)keyName;

- (void)keyPressed:(NSEvent*)event;

- (void)setRepresentedKey:(iTetKeyNamePair*)keyName;
@property (readwrite, retain) NSImage* currentKeyImage;
@property (readwrite, assign) BOOL highlighted;
@property (readonly) NSString* actionName;

@end
