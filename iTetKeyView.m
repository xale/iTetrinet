//
//  iTetKeyView.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/16/09.
//

#import "iTetKeyView.h"

@implementation iTetKeyView

- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	return self;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	// FIXME: WRITEME
}

#define KEY_FONT_SIZE		14
#define KEY_MARGIN_SIZE		10
#define KEY_CORNER_RADIUS	5

- (NSImage*)imageForKey:(NSEvent*)keyEvent
{
	// Get the characters representing the event
	NSString* key = [keyEvent charactersIgnoringModifiers];
	
	// Check if an image for this key exists in cache
	NSImage* image = [NSImage imageNamed:key];
	if (image != nil)
		return image;
	
	// If not, generate an image
	NSSize viewSize = [self bounds].size;
	image = [[[NSImage alloc] initWithSize:viewSize] autorelease];
	
	// Determine the size of the key to draw
	NSRect keyRect = NSMakeRect(0, 0, viewSize.height, viewSize.height);
	
	// FIXME: WRITEME
	
	// Attempt to set the image's name, so it will be stored in cache
	if (![image setName:key])
		NSLog(@"Warning: attempt to name key image \'%@\' failed", key);
	
	return image;
}

- (NSImage*)imageForModifier:(NSEvent*)modifierEvent
{
	// FIXME: WRITEME
	
	return nil;
}

#pragma mark -
#pragma mark Event-Handling

- (void)mouseDown:(NSEvent*)mouseEvent
{
	// Toggle highlighting
	[self setHighlighted:![self highlighted]];
}

- (void)keyDown:(NSEvent*)keyEvent
{
	// If this view is not highlighted, ignore the event
	if (![self highlighted])
		return;
	
	// Pass on to delegate
	if ([[self delegate] respondsToSelector:@selector(keyView:receivedKeyEvent:)])
	{
		[[self delegate] keyView:self
			  receivedKeyEvent:keyEvent];
	}
}

- (void)flagsChanged:(NSEvent*)modifierEvent
{
	// If this view is not highlighted, ignore the event
	if (![self highlighted])
		return;
	
	// Pass on to delegate
	if ([[self delegate] respondsToSelector:@selector(keyView:receivedModifierEvent:)])
	{
		[[self delegate] keyView:self
		   receivedModifierEvent:modifierEvent];
	}
}

#pragma mark -
#pragma mark Accessors

- (void)setRepresentedKey:(NSEvent*)event
{
	switch ([event type])
	{
		case NSKeyDown:
			currentKeyImage = [self imageForKey:event];
			[self setNeedsDisplay:YES];
			break;
		
		case NSFlagsChanged:
			currentKeyImage = [self imageForModifier:event];
			[self setNeedsDisplay:YES];
			break;
		
		default:
			NSLog(@"Warning: attempt to set represented key of an iTetKeyView using an invalid event type");
	}
}

@synthesize highlighted;

@synthesize delegate;

@end
