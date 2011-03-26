//
//  iTetPlayerLevelMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetPlayerLevelMessageTag;

@interface iTetPlayerLevelMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The number of the player whose level is being updated. */
	NSInteger playerLevel;	/*!< The player's new level. */
}

+ (id)messageWithPlayerNumber:(NSInteger)playerNum
						level:(NSInteger)level;
- (id)initWithPlayerNumber:(NSInteger)playerNum
					 level:(NSInteger)level;

@property (readonly) NSInteger playerNumber;
@property (readonly) NSInteger playerLevel;

@end
