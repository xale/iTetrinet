//
//  iTetTextAttributesController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/7/10.
//

#import "iTetTextAttributesController.h"

@implementation iTetTextAttributesController

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Font/color change actions are available if the message field has keyboard focus
	if ([item action] == @selector(changeTextColor:))
	{
		return ([partylineMessageField currentEditor] != nil);
	}
	
	return YES;
}

enum
{
	blackTextColor =		0,
	whiteTextColor =		1,
	grayTextColor =		2,
	silverTextColor =		3,
	redTextColor =		4,
	yellowTextColor =		5,
	limeTextColor =		6,
	greenTextColor =		7,
	oliveTextColor =		8,
	tealTextColor =		9,
	cyanTextColor =		10,
	blueTextColor =		11,
	darkBlueTextColor =	12,
	purpleTextColor =		13,
	maroonTextColor =		14,
	magentaTextColor =	15
};

#define iTetSilverTextColor	[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]
#define iTetGreenTextColor	[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0]
#define iTetOliveTextColor	[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.0 alpha:1.0]
#define iTetTealTextColor	[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.5 alpha:1.0]
#define iTetDarkBlueTextColor	[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.5 alpha:1.0]
#define iTetMaroonTextColor	[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0]

- (IBAction)changeTextColor:(id)sender
{
	NSTextView* editor = (NSTextView*)[partylineMessageField currentEditor];
	
	// Determine the text color to use
	NSColor* textColor;
	switch ([sender tag])
	{
		case blackTextColor:
			textColor = [NSColor blackColor];
			break;
			
		case whiteTextColor:
			textColor = [NSColor whiteColor];
			break;
			
		case grayTextColor:
			textColor = [NSColor grayColor];
			break;
			
		case silverTextColor:
			textColor = iTetSilverTextColor;
			break;
			
		case redTextColor:
			textColor = [NSColor redColor];
			break;
			
		case yellowTextColor:
			textColor = [NSColor yellowColor];
			break;
			
		case limeTextColor:
			textColor = [NSColor greenColor];
			break;
			
		case greenTextColor:
			textColor = iTetGreenTextColor;
			break;
			
		case oliveTextColor:
			textColor = iTetOliveTextColor;
			break;
			
		case tealTextColor:
			textColor = iTetTealTextColor;
			break;
			
		case cyanTextColor:
			textColor = [NSColor cyanColor];
			break;
			
		case blueTextColor:
			textColor = [NSColor blueColor];
			break;
			
		case darkBlueTextColor:
			textColor = iTetDarkBlueTextColor;
			break;
			
		case purpleTextColor:
			textColor = [NSColor purpleColor];
			break;
			
		case maroonTextColor:
			textColor = iTetMaroonTextColor;
			break;
			
		case magentaTextColor:
			textColor = [NSColor magentaColor];
			break;
			
		default:
			return;
	}
	
	// Determine if there is text selected
	NSRange selection = [editor selectedRange];
	if (selection.length > 0)
	{
		// Change the text color of the selection
		[editor setTextColor:textColor
				   range:selection];
	}
	else
	{
		// Set the color of the text being typed
		// Get the current typing attributes
		NSMutableDictionary* attrDict = [[editor typingAttributes] mutableCopy];
		
		// Change the text color
		[attrDict setObject:textColor
				 forKey:NSForegroundColorAttributeName];
		[editor setTypingAttributes:attrDict];
		
		[attrDict release];
	}
}

@end
