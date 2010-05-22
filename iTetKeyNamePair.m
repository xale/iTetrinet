//
//  iTetKeyNamePair.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/12/09.
//

#import "iTetKeyNamePair.h"

@interface iTetKeyNamePair (Private)

- (NSString*)keyNameForEvent:(NSEvent*)event;
- (NSString*)modifierNameForEvent:(NSEvent*)event;

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
		keyName = [[self modifierNameForEvent:event] retain];
	else
	{
		keyName = [[self keyNameForEvent:event] retain];
		
		// Check if the key is on the numeric keypad
		numpadKey = (([event modifierFlags] & NSNumericPadKeyMask) > 0);
	}
	
	return self;
	
}

- (id)initWithKeyCode:(NSInteger)code
				 name:(NSString*)name
			numpadKey:(BOOL)isOnNumpad
{
	keyCode = code;
	keyName = [name copy];
	numpadKey = isOnNumpad;
	
	return self;
}

- (void)dealloc
{
	[keyName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Key Name Lookups

#define EscapeKeyCode	(53)

#define iTetEscapeKeyPlaceholderString	NSLocalizedStringFromTable(@"esc", @"KeyNames", @"Letters appearing on or abbreviation representing the escape key on the keyboard")
#define iTetTabKeyPlaceholderString		NSLocalizedStringFromTable(@"tab", @"KeyNames", @"Name of the 'tab' key, in lowercase")
#define iTetReturnKeyPlaceholderString	NSLocalizedStringFromTable(@"return", @"KeyNames", @"Name of the 'return' key, in lowercase")
#define iTetEnterKeyPlaceholderString	NSLocalizedStringFromTable(@"enter", @"KeyNames", @"Name of the 'enter' key, in lowercase")
#define iTetDeleteKeyPlaceholderString	NSLocalizedStringFromTable(@"delete", @"KeyNames", @"Name of the 'delete' key, in lowercase")

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
			// FIXME: others?
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

#define iTetUnknownModifierPlaceholderString	NSLocalizedStringFromTable(@"(unknown)", @"KeyNames", @"Placeholder string for an unknown modifier key.")
#define iTetShiftKeyPlaceholderString			NSLocalizedStringFromTable(@"shift", @"KeyNames", @"Name of the 'shift' modifier key, in lowercase")
#define iTetControlKeyPlaceholderString			NSLocalizedStringFromTable(@"control", @"KeyNames", @"Name of the 'control' modifier key, in lowercase")
#define iTetAltOptionKeyPlaceholderString		NSLocalizedStringFromTable(@"option", @"KeyNames", @"Name of the 'option' modifier key, in lowercase")
#define iTetCommandKeyPlaceholderString			NSLocalizedStringFromTable(@"command", @"KeyNames", @"Name of the 'command' modifier key, in lowercase")

- (NSString*)modifierNameForEvent:(NSEvent*)modifierEvent
{
	NSString* modifierName = iTetUnknownModifierPlaceholderString;
	
	// Check which modifier is held down
	NSUInteger flags = [modifierEvent modifierFlags];
	if ((flags & NSAlphaShiftKeyMask) || (flags & NSShiftKeyMask))
		modifierName = iTetShiftKeyPlaceholderString;
	else if (flags & NSCommandKeyMask)
		modifierName = iTetCommandKeyPlaceholderString;
	else if (flags & NSAlternateKeyMask)
		modifierName = iTetAltOptionKeyPlaceholderString;
	else if (flags & NSControlKeyMask)
		modifierName = iTetControlKeyPlaceholderString;
	
	return modifierName;
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

- (NSString*)printedName
{
	NSString* name = nil;
	
	if ([[self keyName] rangeOfString:iTetEscapeKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Escape";
	}
	else if ([[self keyName] rangeOfString:iTetSpacebarPlaceholderString].location != NSNotFound)
	{
		name = @"Space";
	}
	else if ([[self keyName] rangeOfString:iTetTabKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Tab";
	}
	else if ([[self keyName] rangeOfString:iTetReturnKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Return";
	}
	else if ([[self keyName] rangeOfString:iTetEnterKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Enter";
	}
	else if ([[self keyName] rangeOfString:iTetDeleteKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Delete";
	}
	else if ([[self keyName] rangeOfString:iTetShiftKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Shift"; // FIXME: left/right?
	}
	else if ([[self keyName] rangeOfString:iTetControlKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Control"; // FIXME: left/right?
	}
	else if ([[self keyName] rangeOfString:iTetAltOptionKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Option"; // FIXME: left/right?
	}
	else if ([[self keyName] rangeOfString:iTetCommandKeyPlaceholderString].location != NSNotFound)
	{
		name = @"Command"; // FIXME: left/right?
	}
	else
	{
		name = [[self keyName] uppercaseString];
	}
	
	if ([self isNumpadKey] && ![self isArrowKey])
		return [NSString stringWithFormat:@"Numpad %@", name];
	
	return name;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<iTetKeyNamePair code:%d name:%@ numpad:%d>", [self keyCode], [self printedName], [self isNumpadKey]];
}

@end
