//
//  NSMutableDictionary+KeyBindings.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/5/09.
//

#import "NSMutableDictionary+KeyBindings.h"
#import "iTetKeyNamePair.h"

NSString* const iTetKeyConfigurationNameKey = @"name";

@implementation NSMutableDictionary (KeyBindings)

+ (NSMutableArray*)defaultKeyConfigurations
{
	NSMutableArray* configs = [NSMutableArray array];
	NSMutableDictionary* keyDict = [NSMutableDictionary dictionary];
	
	// "Arrow Keys" Configuration
	[keyDict setConfigurationName:@"Arrow Keys"];
	[keyDict setAction:movePieceLeft
			  forKey:[iTetKeyNamePair keyNamePairForKeyCode:123
										 name:iTetLeftArrowKeyPlaceholderString]];
	[keyDict setAction:movePieceRight
			  forKey:[iTetKeyNamePair keyNamePairForKeyCode:124
										 name:iTetRightArrowKeyPlaceholderString]];
	[keyDict setAction:rotatePieceCounterclockwise
			  forKey:[iTetKeyNamePair keyNamePairForKeyCode:6
										 name:@"z"]];
	[keyDict setAction:rotatePieceClockwise
			  forKey:[iTetKeyNamePair keyNamePairForKeyCode:7
										 name:@"x"]];
	[keyDict setAction:movePieceDown
			  forKey:[iTetKeyNamePair keyNamePairForKeyCode:125
										 name:iTetDownArrowKeyPlaceholderString]];
	[keyDict setAction:dropPiece
			  forKey:[iTetKeyNamePair keyNamePairForKeyCode:49
										 name:iTetSpacebarPlaceholderString]];
	[keyDict setAction:gameChat
			  forKey:[iTetKeyNamePair keyNamePairForKeyCode:17
										 name:@"t"]];
	[configs addObject:keyDict];
	
	// "MacBook Keyboard" Configuration
	keyDict = [NSMutableDictionary dictionary];
	[keyDict setConfigurationName:@"MacBook Keyboard"];
	[keyDict setAction:movePieceLeft
			forKey:[iTetKeyNamePair keyNamePairForKeyCode:37
									     name:@"l"]];
	[keyDict setAction:movePieceRight
			forKey:[iTetKeyNamePair keyNamePairForKeyCode:39
									     name:@"'"]];
	[keyDict setAction:rotatePieceCounterclockwise
			forKey:[iTetKeyNamePair keyNamePairForKeyCode:31
									     name:@"o"]];
	[keyDict setAction:rotatePieceClockwise
			forKey:[iTetKeyNamePair keyNamePairForKeyCode:35
									     name:@"p"]];
	[keyDict setAction:movePieceDown
			forKey:[iTetKeyNamePair keyNamePairForKeyCode:41
									     name:@";"]];
	[keyDict setAction:dropPiece
			forKey:[iTetKeyNamePair keyNamePairForKeyCode:49
									     name:iTetSpacebarPlaceholderString]];
	[keyDict setAction:gameChat
			forKey:[iTetKeyNamePair keyNamePairForKeyCode:17
									     name:@"t"]];
	[configs addObject:keyDict];
	
	return configs;
}

- (void)setAction:(iTetGameAction)action
	     forKey:(iTetKeyNamePair*)key
{
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
	// We're assuming that a given key can be bound to only one action
	return [[self allKeysForObject:[NSNumber numberWithInt:action]] objectAtIndex:0];
}

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
