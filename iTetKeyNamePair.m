//
//  iTetKeyNamePair.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/12/09.
//

#import "iTetKeyNamePair.h"

@implementation iTetKeyNamePair

+ (id)keyNamePairFromKeyEvent:(NSEvent*)event;
{
	return [[[self alloc] initWithKeyEvent:event] autorelease];
}

+ (id)keyNamePairForKeyCode:(NSInteger)code
					   name:(NSString*)name
{
	return [[[self alloc] initWithKeyCode:code
									 name:name] autorelease];
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
		keyName = [[self keyNameForEvent:event] retain];
	
	return self;
	
}

- (id)initWithKeyCode:(NSInteger)code
				 name:(NSString*)name
{
	keyCode = code;
	keyName = [name copy];
	
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

NSString* const iTetEscapeKeyPlaceholderString =	@"esc";
NSString* const iTetSpacebarPlaceholderString =		@"     space     ";
NSString* const iTetTabKeyPlaceholderString =		@"  tab  ";
NSString* const iTetReturnKeyPlaceholderString =	@"  return  ";
NSString* const iTetEnterKeyPlaceholderString =		@" enter ";
NSString* const iTetDeleteKeyPlaceholderString =	@"  delete  ";

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

NSString* const iTetUnknownModifierPlaceholderString =	@"(unknown)";
NSString* const iTetShiftKeyPlaceholderString =			@"   shift   ";
NSString* const iTetControlKeyPlaceholderString	=		@"control";
NSString* const iTetAltOptionKeyPlaceholderString =		@"option";

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
														 name:[self keyName]];
	
}

- (id)copy
{
	return [self copyWithZone:nil];
}

#pragma mark -
#pragma mark Encoding/Decoding

NSString* const iTetKeyNamePairCodeKey =	@"keyCode";
NSString* const iTetKeyNamePairNameKey =	@"keyName";

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeInteger:[self keyCode]
					forKey:iTetKeyNamePairCodeKey];
	[encoder encodeObject:[self keyName]
				   forKey:iTetKeyNamePairNameKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	keyCode = [decoder decodeIntegerForKey:iTetKeyNamePairCodeKey];
	keyName = [[decoder decodeObjectForKey:iTetKeyNamePairNameKey] retain];
	
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

- (NSString*)printedName
{
	if ([[self keyName] isEqualToString:iTetEscapeKeyPlaceholderString])
		return @"Escape";
	
	if ([[self keyName] isEqualToString:iTetSpacebarPlaceholderString])
		return @"Space";
	
	if ([[self keyName] isEqualToString:iTetTabKeyPlaceholderString])
		return @"Tab";
	
	if ([[self keyName] isEqualToString:iTetReturnKeyPlaceholderString])
		return @"Return";
	
	if ([[self keyName] isEqualToString:iTetEnterKeyPlaceholderString])
		return @"Enter";
	
	if ([[self keyName] isEqualToString:iTetDeleteKeyPlaceholderString])
		return @"Delete";
	
	if ([[self keyName] isEqualToString:iTetShiftKeyPlaceholderString])
		return @"Shift"; // FIXME: left/right?
	
	if ([[self keyName] isEqualToString:iTetControlKeyPlaceholderString])
		return @"Control";
	
	if ([[self keyName] isEqualToString:iTetAltOptionKeyPlaceholderString])
		return @"Option";
	
	if ([[self keyName] isEqualToString:iTetCommandKeyPlaceholderString])
		return @"Command";
	
	return [[self keyName] uppercaseString];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<iTetKeyNamePair code:%d name:%@>", [self keyCode], [self printedName]];
}

@end
