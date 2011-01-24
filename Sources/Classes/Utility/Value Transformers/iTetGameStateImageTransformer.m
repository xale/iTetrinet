//
//  iTetGameStateImageTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGameStateImageTransformer.h"
#import "iTetGameplayState.h"

NSString* const iTetGameStateImageTransformerName = @"TetrinetGameStateTransformer";

@implementation iTetGameStateImageTransformer

+ (Class)transformedValueClass
{
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

NSString* const gameNotPlayingStateImageName =	@"State Icon Stop";
NSString* const gamePlayingStateImageName =		@"State Icon Play";
NSString* const gamePausedStateImageName =		@"State Icon Pause";

- (id)transformedValue:(id)value
{
	// Check that the value to transform is an NSNumber or subclass thereof
	if (![value isKindOfClass:[NSNumber class]])
		return nil;
	
	// Get the integer value, and cast to the game state enum type
	iTetGameplayState state = (iTetGameplayState)[value intValue];
	
	// Return the appropriate image representation
	switch (state)
	{
		case gameNotPlaying:
			return [NSImage imageNamed:gameNotPlayingStateImageName];
		case gamePlaying:
			return [NSImage imageNamed:gamePlayingStateImageName];
		case gamePaused:
			return [NSImage imageNamed:gamePausedStateImageName];
	}
	
	// Unknown state (unlikely to happen)
	return nil;
}

@end
