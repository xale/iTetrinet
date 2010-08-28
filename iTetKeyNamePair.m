//
//  iTetKeyNamePair.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/12/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetKeyNamePair.h"

@interface iTetKeyNamePair (Private)

- (NSString*)keyNameForEvent:(NSEvent*)event;
- (NSString*)modifierNameForEvent:(NSEvent*)event;
- (CGFloat)minimumDisplayWidthForKeyName:(NSString*)name
								onNumpad:(BOOL)isOnNumpad;

@end

@implementation iTetKeyNamePair

+ (id)keyNamePairFromKeyEvent:(NSEvent*)event;
{
	return [[[self alloc] initWithKeyEvent:event] autorelease];
}

+ (id)keyNamePairWithKeyCode:(NSInteger)code
						name:(NSString*)name
{
	return [self keyNamePairWithKeyCode:code
								   name:name
							  numpadKey:NO];
}

+ (id)keyNamePairWithKeyCode:(NSInteger)code
						name:(NSString*)name
				   numpadKey:(BOOL)isOnNumpad
{
	return [[[self alloc] initWithKeyCode:code
									 name:name
								numpadKey:isOnNumpad] autorelease];
}

- (id)initWithKeyEvent:(NSEvent*)event
{
	// Get the key code
	keyCode = [event keyCode];
	
	// Check if the event is a modifier event
	BOOL isModifier = ([event type] == NSFlagsChanged);
	
	// Determine the name of the event
	if (isModifier)
	{
		keyName = [[self modifierNameForEvent:event] retain];
	}
	else
	{
		keyName = [[self keyNameForEvent:event] retain];
		
		// Check if the key is on the numeric keypad
		numpadKey = (([event modifierFlags] & NSNumericPadKeyMask) > 0);
	}
	
	// Set the minimum display width for drawing the key
	minDisplayWidth = [self minimumDisplayWidthForKeyName:keyName
												 onNumpad:numpadKey];
	
	return self;
	
}

- (id)initWithKeyCode:(NSInteger)code
				 name:(NSString*)name
			numpadKey:(BOOL)isOnNumpad
{
	keyCode = code;
	keyName = [name copy];
	numpadKey = isOnNumpad;
	minDisplayWidth = [self minimumDisplayWidthForKeyName:keyName
												 onNumpad:numpadKey];
	
	return self;
}

- (void)dealloc
{
	[keyName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Key Name Lookups

#define EscapeKeyCode	53

#define iTetEscapeKeyPlaceholderString	NSLocalizedStringFromTable(@"esc", @"Keyboard", @"Letters appearing on or abbreviation representing the escape key on the keyboard")
#define iTetTabKeyPlaceholderString		NSLocalizedStringFromTable(@"tab", @"Keyboard", @"Name of the 'tab' key, in lowercase")
#define iTetReturnKeyPlaceholderString	NSLocalizedStringFromTable(@"return", @"Keyboard", @"Name of the 'return' key, in lowercase")
#define iTetEnterKeyPlaceholderString	NSLocalizedStringFromTable(@"enter", @"Keyboard", @"Name of the 'enter' key, in lowercase")
#define iTetDeleteKeyPlaceholderString	NSLocalizedStringFromTable(@"delete", @"Keyboard", @"Name of the 'delete' key, in lowercase")

NSString* const iTetLeftArrowKeyPlaceholderString =		@"←";
NSString* const iTetRightArrowKeyPlaceholderString =	@"→";
NSString* const iTetUpArrowKeyPlaceholderString =		@"↑";
NSString* const iTetDownArrowKeyPlaceholderString =		@"↓";

- (NSString*)keyNameForEvent:(NSEvent*)keyEvent
{
	// Check for events with no characters
	switch ([keyEvent keyCode])
	{
		case EscapeKeyCode:
			return iTetEscapeKeyPlaceholderString;
	}
	
	// Get the characters representing the event
	NSString* keyString = [[keyEvent charactersIgnoringModifiers] lowercaseString];
	
	// Check for various non-printing keys
	unichar key = [keyString characterAtIndex:0];
	switch (key)
	{
		// Space
		case ' ':
			keyString = iTetSpacebarPlaceholderString;
			break;
			// Tab
		case NSTabCharacter:
			keyString = iTetTabKeyPlaceholderString;
			break;
			// Return/Newline
		case NSLineSeparatorCharacter:
		case NSNewlineCharacter:
		case NSCarriageReturnCharacter:
			keyString = iTetReturnKeyPlaceholderString;
			break;
			// Enter
		case NSEnterCharacter:
			keyString = iTetEnterKeyPlaceholderString;
			break;
			// Backspace/delete
		case NSBackspaceCharacter:
		case NSDeleteCharacter:
			keyString = iTetDeleteKeyPlaceholderString;
			break;
			
			// Arrow keys
		case NSLeftArrowFunctionKey:
			keyString = iTetLeftArrowKeyPlaceholderString;
			break;
		case NSRightArrowFunctionKey:
			keyString = iTetRightArrowKeyPlaceholderString;
			break;
		case NSUpArrowFunctionKey:
			keyString = iTetUpArrowKeyPlaceholderString;
			break;
		case NSDownArrowFunctionKey:
			keyString = iTetDownArrowKeyPlaceholderString;
			break;
	}
	// FIXME: Additional non-printing keys?
	
	return keyString;
}

#define CapsLockKeyCode	57

#define iTetCapsLockKeyPlaceholderString		NSLocalizedStringFromTable(@"caps lock", @"Keyboard", @"Name of the 'caps lock' key, in lowercase")
#define iTetShiftKeyPlaceholderString			NSLocalizedStringFromTable(@"shift", @"Keyboard", @"Name of the 'shift' modifier key, in lowercase")
#define iTetControlKeyPlaceholderString			NSLocalizedStringFromTable(@"control", @"Keyboard", @"Name of the 'control' modifier key, in lowercase")
#define iTetAltOptionKeyPlaceholderString		NSLocalizedStringFromTable(@"option", @"Keyboard", @"Name of the 'option' modifier key, in lowercase")
#define iTetCommandKeyPlaceholderString			NSLocalizedStringFromTable(@"command", @"Keyboard", @"Name of the 'command' modifier key, in lowercase")
#define iTetUnknownModifierPlaceholderString	NSLocalizedStringFromTable(@"(unknown)", @"Keyboard", @"Placeholder string for an unknown modifier key")

- (NSString*)modifierNameForEvent:(NSEvent*)modifierEvent
{
	// Check which modifier key has been pressed
	NSUInteger flags = [modifierEvent modifierFlags];
	if ((flags & NSAlphaShiftKeyMask) || (flags & NSShiftKeyMask))
	{
		// Differentiate between shift and caps lock
		if ([modifierEvent keyCode] == CapsLockKeyCode)
		{
			return iTetCapsLockKeyPlaceholderString;
		}
		
		return iTetShiftKeyPlaceholderString;
	}
	if (flags & NSCommandKeyMask)
	{
		return iTetCommandKeyPlaceholderString;
	}
	else if (flags & NSAlternateKeyMask)
	{
		return iTetAltOptionKeyPlaceholderString;
	}
	else if (flags & NSControlKeyMask)
	{
		return iTetControlKeyPlaceholderString;
	}
	
	return iTetUnknownModifierPlaceholderString;
}

#define iTetSpaceKeyMinDisplayWidth			150.0
#define iTetShiftKeyMinDisplayWidth			120.0
#define iTetNumpadZeroKeyMinDisplayWidth	120.0
#define iTetReturnKeyMinDisplayWidth		110.0
#define iTetCapsLockKeyMinDisplayWidth		110.0
#define iTetModifierKeyMinDisplayWidth		100.0
#define iTetTabKeyMinDisplayWidth			90.0
#define iTetDeleteKeyMinDisplayWidth		90.0

NSString* const iTetZeroKeyName =			@"0";

- (CGFloat)minimumDisplayWidthForKeyName:(NSString*)name
								onNumpad:(BOOL)isOnNumPad
{
	if ([name isEqualToString:iTetSpacebarPlaceholderString])
	{
		return iTetSpaceKeyMinDisplayWidth;
	}
	else if ([name isEqualToString:iTetCapsLockKeyPlaceholderString])
	{
		return iTetCapsLockKeyMinDisplayWidth;
	}
	else if ([name isEqualToString:iTetShiftKeyPlaceholderString])
	{
		return iTetShiftKeyMinDisplayWidth;
	}
	else if ([name isEqualToString:iTetReturnKeyPlaceholderString])
	{
		return iTetReturnKeyMinDisplayWidth;
	}
	else if ([name isEqualToString:iTetTabKeyPlaceholderString])
	{
		return iTetTabKeyMinDisplayWidth;
	}
	else if ([name isEqualToString:iTetDeleteKeyPlaceholderString])
	{
		return iTetDeleteKeyMinDisplayWidth;
	}
	else if ([name isEqualToString:iTetCommandKeyPlaceholderString] ||
			 [name isEqualToString:iTetAltOptionKeyPlaceholderString] ||
			 [name isEqualToString:iTetControlKeyPlaceholderString])
	{
		return iTetModifierKeyMinDisplayWidth;
	}
	else if ([name isEqualToString:iTetZeroKeyName] && isOnNumPad)
	{
		return iTetNumpadZeroKeyMinDisplayWidth;
	}
	
	return 0.0;
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
	return [[[self class] allocWithZone:zone] initWithKeyCode:[self keyCode]
														 name:[self keyName]
													numpadKey:[self isNumpadKey]];
	
}

#pragma mark -
#pragma mark Encoding/Decoding

NSString* const iTetKeyNamePairCodeKey =	@"keyCode";
NSString* const iTetKeyNamePairNameKey =	@"keyName";
NSString* const iTetKeyNamePairNumpadKey =	@"numpad";

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeInteger:[self keyCode]
					forKey:iTetKeyNamePairCodeKey];
	[encoder encodeObject:[self keyName]
				   forKey:iTetKeyNamePairNameKey];
	[encoder encodeBool:[self isNumpadKey]
				 forKey:iTetKeyNamePairNumpadKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	keyCode = [decoder decodeIntegerForKey:iTetKeyNamePairCodeKey];
	keyName = [[decoder decodeObjectForKey:iTetKeyNamePairNameKey] retain];
	numpadKey = [decoder decodeBoolForKey:iTetKeyNamePairNumpadKey];
	minDisplayWidth = [self minimumDisplayWidthForKeyName:keyName
												 onNumpad:numpadKey];
	
	return self;
}

#pragma mark -
#pragma mark Comparators

- (BOOL)isEqual:(id)otherObject
{
	if ([otherObject isKindOfClass:[self class]])
	{
		iTetKeyNamePair* otherKey = (iTetKeyNamePair*)otherObject;
		
		return ([self keyCode] == [otherKey keyCode]);
	}
	
	return NO;
}

- (NSUInteger)hash
{
	return (NSUInteger)[self keyCode];
}

#pragma mark -
#pragma mark Accessors

@synthesize keyCode;
@synthesize keyName;
@synthesize numpadKey;
@synthesize minDisplayWidth;

- (BOOL)isArrowKey
{
	switch ([self keyCode])
	{
		case iTetUpArrowKeyCode:
		case iTetDownArrowKeyCode:
		case iTetLeftArrowKeyCode:
		case iTetRightArrowKeyCode:
			return YES;
			
		default:
			break;
	}
	
	return NO;
}

#define iTetEscapeKeyPrintedName	NSLocalizedStringFromTable(@"Escape", @"Keyboard", @"The capitalized full name of the escape key")
#define iTetSpacebarPrintedName		NSLocalizedStringFromTable(@"Space", @"Keyboard", @"The capitalized name of the spacebar")
#define iTetTabKeyPrintedName		NSLocalizedStringFromTable(@"Tab", @"Keyboard", @"The capitalized name of the tab key")
#define iTetReturnKeyPrintedName	NSLocalizedStringFromTable(@"Return", @"Keyboard", @"The capitalized full name of the return key")
#define iTetEnterKeyPrintedName		NSLocalizedStringFromTable(@"Enter", @"Keyboard", @"The capitalized full name of the enter key")
#define iTetDeleteKeyPrintedName	NSLocalizedStringFromTable(@"Delete", @"Keyboard", @"The capitalized full name of the delete key")

#define iTetCapsLockKeyPrintedName	NSLocalizedStringFromTable(@"Caps Lock", @"Keyboard", @"The capitalized full name of the caps lock key")
#define iTetShiftKeyPrintedName		NSLocalizedStringFromTable(@"Shift", @"Keyboard", @"The capitalized full name of the shift modifier key")
#define iTetControlKeyPrintedName	NSLocalizedStringFromTable(@"Control", @"Keyboard", @"The capitalized full name of the control modifier key")
#define iTetOptionKeyPrintedName	NSLocalizedStringFromTable(@"Option", @"Keyboard", @"The capitalized full name of the option modifier key")
#define iTetCommandKeyPrintedName	NSLocalizedStringFromTable(@"Command", @"Keyboard", @"The capitalized full name of the command modifier key")

#define iTetNumpadPrintedNameFormat	NSLocalizedStringFromTable(@"Numpad %@", @"Keyboard", @"Format for printed name of keys on the numeric keypad")

- (NSString*)printedName
{
	NSString* name = nil;
	
	if ([[self keyName] isEqualToString:iTetEscapeKeyPlaceholderString])
	{
		name = iTetEscapeKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetSpacebarPlaceholderString])
	{
		name = iTetSpacebarPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetTabKeyPlaceholderString])
	{
		name = iTetTabKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetReturnKeyPlaceholderString])
	{
		name = iTetReturnKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetEnterKeyPlaceholderString])
	{
		name = iTetEnterKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetDeleteKeyPlaceholderString])
	{
		name = iTetDeleteKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetCapsLockKeyPlaceholderString])
	{
		name = iTetCapsLockKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetShiftKeyPlaceholderString])
	{
		name = iTetShiftKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetControlKeyPlaceholderString])
	{
		name = iTetControlKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetAltOptionKeyPlaceholderString])
	{
		name = iTetOptionKeyPrintedName;
	}
	else if ([[self keyName] isEqualToString:iTetCommandKeyPlaceholderString])
	{
		name = iTetCommandKeyPrintedName;
	}
	else
	{
		name = [[self keyName] uppercaseString];
	}
	
	if ([self isNumpadKey] && ![self isArrowKey])
		return [NSString stringWithFormat:iTetNumpadPrintedNameFormat, name];
	
	return name;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<iTetKeyNamePair code:%d name:%@ numpad:%d>", [self keyCode], [self printedName], [self isNumpadKey]];
}

@end
