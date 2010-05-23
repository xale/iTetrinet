//
//  iTetKeyConfiguration.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/5/09.
//

#import "iTetKeyConfiguration.h"
#import "iTetKeyNamePair.h"

#import "iTetUserDefaults.h"
#import "NSUserDefaults+AdditionalTypes.h"

#define iTetZKeyCode			(6)
#define iTetXKeyCode			(7)
#define iTetSpacebarKeyCode		(49)
#define iTetDKeyCode			(2)
#define iTetSKeyCode			(1)
#define iTetTKeyCode			(17)
#define iTetLKeyCode			(37)
#define iTetApostropheKeyCode	(39)
#define iTetOKeyCode			(31)
#define iTetPKeyCode			(35)
#define iTetSemicolonKeyCode	(41)

#define iTet1KeyCode			(18)
#define iTet2KeyCode			(19)
#define iTet3KeyCode			(20)
#define iTet4KeyCode			(21)
#define iTet5KeyCode			(23)
#define iTet6KeyCode			(22)

@interface NSDictionary (KeyBindings)

+ (NSDictionary*)specialTargetsDictionary;

@end

@interface NSMutableDictionary (KeyBindings)

+ (NSMutableDictionary*)bareKeyConfigurationDictionary;

@end

@interface iTetKeyConfiguration (Private)

- (id)initWithConfigurationName:(NSString*)configName
					keyBindings:(NSMutableDictionary*)bindings;

@end

@implementation iTetKeyConfiguration

+ (void)initialize
{
	if (self == [iTetKeyConfiguration class])
	{
		NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[iTetKeyConfiguration defaultKeyConfigurations]]
					 forKey:iTetKeyConfigsListPrefKey];
		[defaults setObject:[NSNumber numberWithUnsignedInt:0]
					 forKey:iTetCurrentKeyConfigNumberPrefKey];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	}
}

+ (iTetKeyConfiguration*)currentKeyConfiguration
{
	NSArray* configs = [[NSUserDefaults standardUserDefaults] unarchivedObjectForKey:iTetKeyConfigsListPrefKey];
	NSUInteger configNum = [[NSUserDefaults standardUserDefaults] unsignedIntegerForKey:iTetCurrentKeyConfigNumberPrefKey];
	return [configs objectAtIndex:configNum];
}

#define	iTetArrowKeysKeyboardConfigurationName	NSLocalizedStringFromTable(@"Arrow Keys", @"KeyConfigurations", @"Name of a built-in key configuration that uses the arrow keys for moving the falling piece")
#define iTetMacBookKeyboardConfigurationName	NSLocalizedStringFromTable(@"MacBook Keyboard", @"KeyConfigurations", @"Name of a built-in key configuration intended for use with small-form keyboards (such as the MacBook's)")

+ (NSMutableArray*)defaultKeyConfigurations
{
	NSMutableArray* configs = [NSMutableArray array];
	
	// "Arrow Keys" Configuration
	iTetKeyConfiguration* config = [iTetKeyConfiguration keyConfigurationWithName:iTetArrowKeysKeyboardConfigurationName];
	[config setAction:movePieceLeft
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetLeftArrowKeyCode
														 name:iTetLeftArrowKeyPlaceholderString]];
	[config setAction:movePieceRight
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetRightArrowKeyCode
														 name:iTetRightArrowKeyPlaceholderString]];
	[config setAction:rotatePieceCounterclockwise
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetZKeyCode
														 name:@"z"]];
	[config setAction:rotatePieceClockwise
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetXKeyCode
														 name:@"x"]];
	[config setAction:movePieceDown
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetDownArrowKeyCode
														 name:iTetDownArrowKeyPlaceholderString]];
	[config setAction:dropPiece
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetSpacebarKeyCode
														 name:iTetSpacebarPlaceholderString]];
	[config setAction:discardSpecial
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetDKeyCode
														 name:@"d"]];
	[config setAction:selfSpecial
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetSKeyCode
														 name:@"s"]];
	[config setAction:gameChat
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetTKeyCode
														 name:@"t"]];
	[configs addObject:config];
	
	// "MacBook Keyboard" Configuration
	config = [iTetKeyConfiguration keyConfigurationWithName:iTetMacBookKeyboardConfigurationName];
	[config setAction:movePieceLeft
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetLKeyCode
														 name:@"l"]];
	[config setAction:movePieceRight
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetApostropheKeyCode
														 name:@"'"]];
	[config setAction:rotatePieceCounterclockwise
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetOKeyCode
														 name:@"o"]];
	[config setAction:rotatePieceClockwise
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetPKeyCode
														 name:@"p"]];
	[config setAction:movePieceDown
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetSemicolonKeyCode
														 name:@";"]];
	[config setAction:dropPiece
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetSpacebarKeyCode
														 name:iTetSpacebarPlaceholderString]];
	[config setAction:discardSpecial
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetDKeyCode
														 name:@"d"]];
	[config setAction:selfSpecial
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetSKeyCode
														 name:@"s"]];
	[config setAction:gameChat
		forKeyBinding:[iTetKeyNamePair keyNamePairWithKeyCode:iTetTKeyCode
														 name:@"t"]];
	[configs addObject:config];
	
	return configs;
}

+ (id)keyConfiguration
{
	return [[[self alloc] init] autorelease];
}

+ (id)keyConfigurationWithName:(NSString*)configName
{
	return [[[self alloc] initWithConfigurationName:configName] autorelease];
}

- (id)initWithConfigurationName:(NSString*)configName
{
	return [self initWithConfigurationName:configName
							   keyBindings:[NSMutableDictionary bareKeyConfigurationDictionary]];
}

- (id)initWithConfigurationName:(NSString*)configName
					keyBindings:(NSMutableDictionary*)bindings
{
	configurationName = [configName copy];
	keyBindings = [bindings retain];
	
	return self;
}

#define iTetUntitledKeyboardConfigurationName	NSLocalizedStringFromTable(@"Untitled Key Configuration", @"KeyConfigurations", @"Placeholder name for new or untitled keyboard configurations")

- (id)init
{
	return [self initWithConfigurationName:iTetUntitledKeyboardConfigurationName];
}

- (void)dealloc
{
	[configurationName release];
	[keyBindings release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCopying Protocol Methods

- (id)copyWithZone:(NSZone*)zone
{
	return [[iTetKeyConfiguration allocWithZone:zone] initWithConfigurationName:configurationName
																	keyBindings:keyBindings];
}

#pragma mark -
#pragma mark NSCoding Protocol Methods

NSString* const iTetKeyConfigurationNameKey =		@"configurationName";
NSString* const iTetKeyConfigurationBindingsKey =	@"keyBindings";

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:configurationName
				   forKey:iTetKeyConfigurationNameKey];
	[encoder encodeObject:keyBindings
				   forKey:iTetKeyConfigurationBindingsKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	return [self initWithConfigurationName:[decoder decodeObjectForKey:iTetKeyConfigurationNameKey]
							   keyBindings:[decoder decodeObjectForKey:iTetKeyConfigurationBindingsKey]];
}

#pragma mark -
#pragma mark Accessors

- (iTetGameAction)actionForKeyBinding:(iTetKeyNamePair*)key
{
	NSNumber* action = [keyBindings objectForKey:key];
	
	if (action != nil)
		return (iTetGameAction)[action intValue];
	
	return noAction;
}

- (iTetKeyNamePair*)keyBindingForAction:(iTetGameAction)action
{
	NSArray* keys = [keyBindings allKeysForObject:[NSNumber numberWithInt:action]];
	
	if ([keys count] > 0)
		return [keys objectAtIndex:0];
	
	return nil;
}

- (void)setAction:(iTetGameAction)action
	forKeyBinding:(iTetKeyNamePair*)key
{
	// Remove the previous keybinding
	iTetKeyNamePair* oldKey = [self keyBindingForAction:action];
	if (oldKey != nil)
		[keyBindings removeObjectForKey:oldKey];
	
	[keyBindings setObject:[NSNumber numberWithInt:action]
					forKey:key];
}

@synthesize configurationName;

@end

@implementation NSDictionary (KeyBindings)

+ (NSDictionary*)specialTargetsDictionary
{
	// Create a dictionary with the special-targeting keys
	NSMutableDictionary* targetKeys = [NSMutableDictionary dictionary];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer1]
				   forKey:[iTetKeyNamePair keyNamePairWithKeyCode:iTet1KeyCode
															 name:@"1"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer2]
				   forKey:[iTetKeyNamePair keyNamePairWithKeyCode:iTet2KeyCode
															 name:@"2"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer3]
				   forKey:[iTetKeyNamePair keyNamePairWithKeyCode:iTet3KeyCode
															 name:@"3"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer4]
				   forKey:[iTetKeyNamePair keyNamePairWithKeyCode:iTet4KeyCode
															 name:@"4"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer5]
				   forKey:[iTetKeyNamePair keyNamePairWithKeyCode:iTet5KeyCode
															 name:@"5"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer6]
				   forKey:[iTetKeyNamePair keyNamePairWithKeyCode:iTet6KeyCode
															 name:@"6"]];
	return targetKeys;
}

@end

@implementation NSMutableDictionary (KeyBindings)

+ (NSMutableDictionary*)bareKeyConfigurationDictionary
{
	NSMutableDictionary* keyDict = [NSMutableDictionary dictionary];
	
	[keyDict addEntriesFromDictionary:[NSDictionary specialTargetsDictionary]];
	
	return keyDict;
}

@end
