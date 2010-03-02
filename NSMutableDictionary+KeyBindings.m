//
//  NSMutableDictionary+KeyBindings.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/5/09.
//

#import "NSMutableDictionary+KeyBindings.h"
#import "iTetKeyNamePair.h"

#define iTetLeftArrowKeyCode	(123)
#define iTetRightArrowKeyCode	(124)
#define iTetZKeyCode			(6)
#define iTetXKeyCode			(7)
#define iTetDownArrowKeyCode	(125)
#define iTetSpacebarKeyCode		(49)
#define iTetDKeyCode			(2)
#define iTetSKeyCode			(1)
#define iTetTKeyCode			(17)
#define iTetLKeyCode			(37)
#define iTetApostropheKeyCode	(39)
#define iTetOKeyCode			(31)
#define iTetPKeyCode			(35)
#define iTetSemicolonKeyCode	(41)

@implementation NSMutableDictionary (KeyBindings)

+ (NSMutableArray*)defaultKeyConfigurations
{
	NSMutableArray* configs = [NSMutableArray array];
	
	// "Arrow Keys" Configuration
	NSMutableDictionary* keyDict = [NSMutableDictionary keyConfigurationDictionary];
	[keyDict setConfigurationName:@"Arrow Keys"];
	[keyDict setAction:movePieceLeft
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetLeftArrowKeyCode
														 name:iTetLeftArrowKeyPlaceholderString]];
	[keyDict setAction:movePieceRight
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetRightArrowKeyCode
														 name:iTetRightArrowKeyPlaceholderString]];
	[keyDict setAction:rotatePieceCounterclockwise
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetZKeyCode
														 name:@"z"]];
	[keyDict setAction:rotatePieceClockwise
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetXKeyCode
														 name:@"x"]];
	[keyDict setAction:movePieceDown
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetDownArrowKeyCode
														 name:iTetDownArrowKeyPlaceholderString]];
	[keyDict setAction:dropPiece
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetSpacebarKeyCode
														 name:iTetSpacebarPlaceholderString]];
	[keyDict setAction:discardSpecial
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetDKeyCode
														 name:@"d"]];
	[keyDict setAction:selfSpecial
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetSKeyCode
														 name:@"s"]];
	[keyDict setAction:gameChat
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetTKeyCode
														 name:@"t"]];
	[configs addObject:keyDict];
	
	// "MacBook Keyboard" Configuration
	keyDict = [NSMutableDictionary keyConfigurationDictionary];
	[keyDict setConfigurationName:@"MacBook Keyboard"];
	[keyDict setAction:movePieceLeft
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetLKeyCode
														 name:@"l"]];
	[keyDict setAction:movePieceRight
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetApostropheKeyCode
														 name:@"'"]];
	[keyDict setAction:rotatePieceCounterclockwise
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetOKeyCode
														 name:@"o"]];
	[keyDict setAction:rotatePieceClockwise
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetPKeyCode
														 name:@"p"]];
	[keyDict setAction:movePieceDown
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetSemicolonKeyCode
														 name:@";"]];
	[keyDict setAction:dropPiece
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetSpacebarKeyCode
														 name:iTetSpacebarPlaceholderString]];
	[keyDict setAction:discardSpecial
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetDKeyCode
														 name:@"d"]];
	[keyDict setAction:selfSpecial
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetSKeyCode
														 name:@"s"]];
	[keyDict setAction:gameChat
				forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTetTKeyCode
														 name:@"t"]];
	[configs addObject:keyDict];
	
	return configs;
}

+ (NSMutableDictionary*)keyConfigurationDictionary
{
	NSMutableDictionary* keyDict = [NSMutableDictionary dictionary];
	[keyDict setConfigurationName:@"Untitled Key Configuration"];
	
	[keyDict addEntriesFromDictionary:[NSMutableDictionary specialTargetsDictionary]];
	
	return keyDict;
}

#define iTet1KeyCode	(18)
#define iTet2KeyCode	(19)
#define iTet3KeyCode	(20)
#define iTet4KeyCode	(21)
#define iTet5KeyCode	(23)
#define iTet6KeyCode	(22)

+ (NSDictionary*)specialTargetsDictionary
{
	// Create a dictionary with the special-targeting keys
	NSMutableDictionary* targetKeys = [NSMutableDictionary dictionary];
	[targetKeys setAction:specialPlayer1
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet1KeyCode
															name:@"1"]];
	[targetKeys setAction:specialPlayer2
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet2KeyCode
															name:@"2"]];
	[targetKeys setAction:specialPlayer3
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet3KeyCode
															name:@"3"]];
	[targetKeys setAction:specialPlayer4
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet4KeyCode
															name:@"4"]];
	[targetKeys setAction:specialPlayer5
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet5KeyCode
															name:@"5"]];
	[targetKeys setAction:specialPlayer6
				   forKey:[iTetKeyNamePair keyNamePairForKeyCode:iTet6KeyCode
															name:@"6"]];
	return targetKeys;
}

- (void)setAction:(iTetGameAction)action
		   forKey:(iTetKeyNamePair*)key
{
	// Remove the previous keybinding
	iTetKeyNamePair* oldKey = [self keyForAction:action];
	if (oldKey)
		[self removeObjectForKey:oldKey];
	
	[self setObject:[NSNumber numberWithInt:action]
			 forKey:key];
}

- (iTetGameAction)actionForKey:(iTetKeyNamePair*)key
{
	NSNumber* action = [self objectForKey:key];
	
	if (action)
		return (iTetGameAction)[action intValue];
	
	return noAction;
}

- (iTetKeyNamePair*)keyForAction:(iTetGameAction)action
{
	NSArray* keys = [self allKeysForObject:[NSNumber numberWithInt:action]];
	
	if ([keys count] > 0)
		return [keys objectAtIndex:0];
	
	return nil;
}

NSString* const iTetKeyConfigurationNameKey = @"name";

- (NSString*)configurationName
{
	return [self objectForKey:iTetKeyConfigurationNameKey];
}

- (void)setConfigurationName:(NSString*)newName
{
	[self setObject:newName
			 forKey:iTetKeyConfigurationNameKey];
}

@end
