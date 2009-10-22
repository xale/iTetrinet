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
	
	IBOutlet id delegate;
}

- (NSString*)keyNameForEvent:(NSEvent*)event;
- (NSString*)modifierNameForEvent:(NSEvent*)event;
- (NSImage*)keyImageWithString:(NSString*)keyName;

- (void)setRepresentedKeyName:(NSString*)keyName;
@property (readwrite, retain) NSImage* currentKeyImage;
@property (readwrite, assign) BOOL highlighted;

@end
