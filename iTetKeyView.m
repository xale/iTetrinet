//
//  iTetKeyView.m
//  iTetrinet
//
//  Created by Alex Heinz on 10/16/09.
//

#import "iTetKeyView.h"
#import "iTetKeyNamePair.h"
#import "iTetKeyboardViewController.h" // Quiets warnings on delegate methods
#import "NSImage+KeyImageCache.h"

@implementation iTetKeyView

- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	currentKeyImage = [[self keyImageWithString:@"a"] retain];
	
	return self;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	// Draw highlight background, if applicable
	if ([self highlighted])
	{
		// FIXME: make this prettier
		[[NSColor alternateSelectedControlColor] set];
		[NSBezierPath fillRect:[self bounds]];
	}
	
	if (currentKeyImage == nil)
		return;
	
	// Center the key image
	NSPoint drawPoint = NSZeroPoint;
	drawPoint.x = (([self bounds].size.width - [currentKeyImage size].width) / 2);
	
	// Draw the image
	[currentKeyImage drawAtPoint:drawPoint
						fromRect:NSZeroRect
					   operation:NSCompositeSourceOver
						fraction:1.0];
}

NSString* const iTetKeyFontName =	@"Helvetica";
#define KEY_LINE_COLOR			[NSColor grayColor]
#define KEY_FILL_COLOR			[NSColor whiteColor]
#define KEY_FONT_SIZE			(22.0)
#define KEY_NAME_MARGIN_SIZE	(10)
#define KEY_BORDER_WIDTH		(2)
#define KEY_CORNER_RADIUS		(5)

- (NSImage*)keyImageWithString:(NSString*)keyName
{	
	// Check if an image for this key exists in cache
	NSImage* image = [NSImage imageForKeyName:keyName];
	if (image != nil)
		return image;
	
	// If no image in cache, generate one
	// Begin by creating an attributed string
	NSFont* drawFont = [NSFont fontWithName:iTetKeyFontName
									   size:KEY_FONT_SIZE];
	NSDictionary* attrDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  drawFont, NSFontAttributeName,
							  KEY_LINE_COLOR, NSForegroundColorAttributeName,
							  nil];
	NSAttributedString* drawString = [[[NSAttributedString alloc] initWithString:keyName
																	  attributes:attrDict] autorelease];
	
	// Determine the size of the string to draw
	NSSize stringSize = [drawString size];
	
	// Retrieve the view's size
	NSSize viewSize = [self bounds].size;
	
	// Create the rect in which we will draw the key
	NSRect imageRect = NSMakeRect(0, 0,
								  stringSize.width + (KEY_NAME_MARGIN_SIZE * 2),
								  viewSize.height);
	
	// If the rect is taller than it is wide, make it square
	if (imageRect.size.height > imageRect.size.width)
		imageRect.size.width = imageRect.size.height;
	
	// Create the image
	image = [[[NSImage alloc] initWithSize:imageRect.size] autorelease];
	[image lockFocus];
	
	// Create the actual drawn rect (by subtracting the thickness of the border)
	NSRect keyBorderRect = imageRect;
	keyBorderRect.origin.x += (KEY_BORDER_WIDTH / 2);
	keyBorderRect.origin.y += (KEY_BORDER_WIDTH / 2);
	keyBorderRect.size.width -= KEY_BORDER_WIDTH;
	keyBorderRect.size.height -= KEY_BORDER_WIDTH;
	
	// Create a bezier path for the border of the key
	NSBezierPath* keyBorder = [NSBezierPath bezierPathWithRoundedRect:keyBorderRect
															  xRadius:KEY_CORNER_RADIUS
															  yRadius:KEY_CORNER_RADIUS];
	[keyBorder setLineWidth:KEY_BORDER_WIDTH];
	
	// Fill the path
	[KEY_FILL_COLOR set];
	[keyBorder fill];
	
	// Stroke the border
	[KEY_LINE_COLOR set];
	[keyBorder stroke];
	
	// Determine the point to draw the key name
	NSPoint stringDrawPoint = NSMakePoint(((imageRect.size.width - stringSize.width)/2),
										  ((imageRect.size.height - stringSize.height)/2));
	
	// Draw the key name
	[drawString drawAtPoint:stringDrawPoint];
	
	// Finished drawing
	[image unlockFocus];
	
	// Store the image in cache, for later access
	[NSImage setImage:image
		   forKeyName:keyName];
	
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
	[self keyPressed:[iTetKeyNamePair keyNamePairFromKeyEvent:keyEvent]];
}

- (void)flagsChanged:(NSEvent*)modifierEvent
{	
	[self keyPressed:[iTetKeyNamePair keyNamePairFromKeyEvent:modifierEvent]];
}

- (void)keyPressed:(iTetKeyNamePair*)key
{
	// If this view is not highlighted, ignore the event
	if (![self highlighted])
		return;
	
	// If we have no delegate, or the delegate isn't interested, ignore
	if ((delegate == nil) || !([delegate respondsToSelector:@selector(keyView:shouldSetRepresentedKey:)]))
		return;
	
	// Ask the delegate if the view's represented key should be changed
	if ([delegate keyView:self shouldSetRepresentedKey:key])
	{
		[self setRepresentedKey:key];
		
		if ([delegate respondsToSelector:@selector(keyView:didSetRepresentedKey:)])
			[delegate keyView:self didSetRepresentedKey:key];
	}
	
	// Clear highlight
	[self setHighlighted:NO];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isOpaque
{
	return NO;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{	
	// Ask superclass if it is okay to resign first responder
	BOOL shouldResign = [super resignFirstResponder];
	
	// If we should resign, un-highlight the view before doing so
	if (shouldResign)
		[self setHighlighted:NO];
	
	return shouldResign;
}

- (void)setRepresentedKey:(iTetKeyNamePair*)key
{
	[self setCurrentKeyImage:[self keyImageWithString:[key keyName]]];
}

- (void)setAssociatedAction:(iTetGameAction)action
{
	associatedAction = action;
	
	[actionNameField setStringValue:iTetNameForAction(associatedAction)];
}
@synthesize associatedAction;

- (void)setCurrentKeyImage:(NSImage*)image
{
	[image retain];
	[currentKeyImage release];
	currentKeyImage = image;
	[self setNeedsDisplay:YES];
}
@synthesize currentKeyImage;

- (void)setHighlighted:(BOOL)turnOn
{
	if ((highlighted && !turnOn) || (!highlighted && turnOn))
	{
		highlighted = turnOn;
		[self setNeedsDisplay:YES];
	}
}
@synthesize highlighted;

@end
