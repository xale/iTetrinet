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

NSString* const iTetSpacebarPlaceholderString = @"space";

- (NSImage*)imageForKey:(NSEvent*)keyEvent
{
	// Get the characters representing the event
	NSString* key = [keyEvent charactersIgnoringModifiers];
	
	// Check for various non-printing keys
	// Space
	if ([key isEqualToString:@" "])
		key = iTetSpacebarPlaceholderString;
	// FIXME: Additional non-printing keys
	
	return [self keyImageWithString:key];
}

NSString* const iTetUnknownModifierPlaceholderString = @"(unknown)";
NSString* const iTetShiftKeyPlaceholderString =		@"shift";
NSString* const iTetControlKeyPlaceholderString =	@"control";
NSString* const iTetAltOptionKeyPlaceholderString =	@"option";
NSString* const iTetCommandKeyPlaceholderString =	[NSString stringWithFormat:@"%C  %C", 0xF8FF, 0x2318];
// The above should render as the unicode Apple logo followed by the unicode cloverleaf

- (NSImage*)imageForModifier:(NSEvent*)modifierEvent
{
	NSString* modifierName = iTetUnknownModifierPlaceholderString;
	
	// Check which modifier is held down
	NSUInteger flags = [modifierEvent modifierFlags];
	if ((flags & NSAlphaShiftKeyMask) || (flags & NSShiftKeyMask))
		modifierName = iTetShiftKeyPlaceholderString;
	else if (flags & NSControlKeyMask)
		modifierName = iTetControlKeyPlaceholderString;
	else if (flags & NSAlternateKeyMask)
		modifierName = iTetAltOptionKeyPlaceholderString;
	else if (flags & NSCommandKeyMask)
		modifierName = iTetCommandKeyPlaceholderString;
	
	return [self keyImageWithString:modifierName];
}

NSString* const iTetKeyFontName = @"Helvetica";
#define KEY_FONT_SIZE		(14.0)
#define KEY_MARGIN_SIZE		(10)
#define KEY_CORNER_RADIUS	(5)
		
- (NSImage*)keyImageWithString:(NSString*)keyName
{
	// Check if an image for this key exists in cache
	NSImage* image = [NSImage imageNamed:keyName];
	if (image != nil)
		return image;
	
	// If no image in cache, generate one
	// Begin by creating an attributed string
	NSFont* drawFont = [NSFont fontWithName:iTetKeyFontName
						     size:KEY_FONT_SIZE];
	// FIXME: create text color; place attributes in dictionary
	
	NSAttributedString* drawString = [[[NSAttributedString alloc] initWithString:keyName] autorelease];
	
	// FIXME: draw image
	
	// Attempt to set the image's name, so it will be stored in cache (if this
	// fails, for any reason, we will just re-generate the image next time)
	[image setName:keyName];
	
	return image;
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
