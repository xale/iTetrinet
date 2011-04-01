//
//  iTetStartStopGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/1/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"
#import "iTetGameplayState.h"

extern NSString* const iTetStartStopGameMessageTag;

@interface iTetStartStopGameMessage : iTetMessage
{
	NSInteger senderPlayerNumber;	/*!< The player-slot-number of the player sending the start/stop request. */
	iTetStartStopState startState;	/*!< Specifies whether the game should be started or stopped. */
}

+ (id)startGameMessageFromPlayer:(NSInteger)playerNumber;
+ (id)stopGameMessageFromPlayer:(NSInteger)playerNumber;
- (id)initWithPlayerNumber:(NSInteger)playerNumber
				startState:(iTetStartStopState)state;

@property (readonly) NSInteger senderPlayerNumber;
@property (readonly) iTetStartStopState startState;

@end
