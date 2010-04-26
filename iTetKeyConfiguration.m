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

+ (NSMutableArray*)defaultKeyConfigurations
{
	NSMutableArray* configs = [NSMutableArray array];
	
	// "Arrow Keys" Configuration
	iTetKeyConfiguration* config = [iTetKeyConfiguration keyConfigurationWithName:@"Arrow Keys"];
	[config setAction:movePieceLeft
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetLeftArrowKeyCode
														name:iTetLeftArrowKeyPlaceholderString]];
	[config setAction:movePieceRight
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetRightArrowKeyCode
														name:iTetRightArrowKeyPlaceholderString]];
	[config setAction:rotatePieceCounterclockwise
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetZKeyCode
														name:@"z"]];
	[config setAction:rotatePieceClockwise
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetXKeyCode
														name:@"x"]];
	[config setAction:movePieceDown
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetDownArrowKeyCode
														name:iTetDownArrowKeyPlaceholderString]];
	[config setAction:dropPiece
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetSpacebarKeyCode
														name:iTetSpacebarPlaceholderString]];
	[config setAction:discardSpecial
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetDKeyCode
														name:@"d"]];
	[config setAction:selfSpecial
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetSKeyCode
														name:@"s"]];
	[config setAction:gameChat
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetTKeyCode
														name:@"t"]];
	[configs addObject:config];
	
	// "MacBook Keyboard" Configuration
	config = [iTetKeyConfiguration keyConfigurationWithName:@"MacBook Keyboard"];
	[config setAction:movePieceLeft
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetLKeyCode
														name:@"l"]];
	[config setAction:movePieceRight
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetApostropheKeyCode
														name:@"'"]];
	[config setAction:rotatePieceCounterclockwise
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetOKeyCode
														name:@"o"]];
	[config setAction:rotatePieceClockwise
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetPKeyCode
														name:@"p"]];
	[config setAction:movePieceDown
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetSemicolonKeyCode
														name:@";"]];
	[config setAction:dropPiece
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetSpacebarKeyCode
														name:iTetSpacebarPlaceholderString]];
	[config setAction:discardSpecial
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetDKeyCode
														name:@"d"]];
	[config setAction:selfSpecial
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetSKeyCode
														name:@"s"]];
	[config setAction:gameChat
		forKeyBinding:[iTetKeyNamePair keyNamePairForKeyCode:iTetTKeyCode
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

NSString* const iTetUntitledKeyConfigurationPlaceholderName =	@"Untitled Key Configuration";

- (id)init
{
	return [self initWithConfigurationName:iTetUntitledKeyConfigurationPlaceholderName];
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
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet1KeyCode
															name:@"1"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer2]
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet2KeyCode
															name:@"2"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer3]
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet3KeyCode
															name:@"3"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer4]
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet4KeyCode
															name:@"4"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer5]
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet5KeyCode
															name:@"5"]];
	[targetKeys setObject:[NSNumber numberWithInt:specialPlayer6]
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet6KeyCode
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
