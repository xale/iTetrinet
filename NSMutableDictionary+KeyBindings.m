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
	
	[keyDict setObject:@"Arrow Keys"
			  forKey:iTetKeyConfigurationNameKey];
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
	
	// FIXME: more default configurations
	
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
