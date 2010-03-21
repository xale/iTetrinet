//
//  iTetTextAttributesController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/7/10.
//

#import "iTetTextAttributesController.h"
#import "iTetTextAttributes.h"

@implementation iTetTextAttributesController

#pragma mark -
#pragma mark Interface Actions

- (IBAction)changeTextColor:(id)sender
{
	NSTextView* editor = (NSTextView*)[partylineMessageField currentEditor];
	
	// Determine the text color to use
	NSColor* textColor = [iTetTextAttributes textColorForCode:[sender tag]];
	
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

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Color change actions are available if the message field has keyboard focus
	if ([item action] == @selector(changeTextColor:))
		return ([partylineMessageField currentEditor] != nil);
	
	return YES;
}

@end
