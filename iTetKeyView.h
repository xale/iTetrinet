//
//  iTetKeyView.h
//  iTetrinet
//
//  Created by Alex Heinz on 10/16/09.
//

#import <Cocoa/Cocoa.h>

@interface iTetKeyView : NSView
{	
	NSImage* currentKeyImage;
	BOOL highlighted;
	
	id delegate;
}

- (NSImage*)imageForKey:(NSEvent*)keyEvent;
- (NSImage*)imageForModifier:(NSEvent*)modifierEvent;

- (void)setRepresentedKey:(NSEvent*)keyEvent;
@property (readwrite, assign) BOOL highlighted;
@property (readwrite, assign) id delegate;

@end
