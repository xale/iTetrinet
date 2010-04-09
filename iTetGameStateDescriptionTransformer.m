//
//  iTetGameStateDescriptionTransformer.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//

#import "iTetGameStateDescriptionTransformer.h"
#import "iTetGameplayState.h"

NSString* const iTetGameStateDescriptionTransformerName = @"TetrinetGameStateTransformer";

@implementation iTetGameStateDescriptionTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

NSString* const gameNotPlayingStateDescription =	@"Game Over";
NSString* const gamePlayingStateDescription =		@"In-Game";
NSString* const gamePausedStateDescription =		@"Paused";
NSString* const unknownGameStateDescription =		@"Unknown";

- (id)transformedValue:(id)value
{
	// Check that the value to transform is an NSNumber or subclass thereof
	if (![value isKindOfClass:[NSNumber class]])
		return unknownGameStateDescription;
	
	// Get the integer value, and cast to the game state enum type
	iTetGameplayState state = (iTetGameplayState)[value intValue];
	
	// Return the appropriate string representation
	switch (state)
	{
		case gameNotPlaying:
			return gameNotPlayingStateDescription;
		case gamePlaying:
			return gamePlayingStateDescription;
		case gamePaused:
			return gamePausedStateDescription;
	}
	
	// Unknown state (unlikely to happen)
	return unknownGameStateDescription;
}

@end
