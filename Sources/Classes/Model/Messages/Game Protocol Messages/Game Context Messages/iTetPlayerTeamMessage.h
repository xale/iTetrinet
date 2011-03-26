//
//  iTetPlayerTeamMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/22/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetPlayerTeamMessageTag;

@interface iTetPlayerTeamMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The player-slot-number of the player whose team has changed. */
	NSString* playerTeamName;	/*!< The player's new team name. May be blank, and may contain whitespace. */
}

+ (id)messageWithPlayerNumber:(NSInteger)number
					 teamName:(NSString*)teamName;
- (id)initWithPlayerNumber:(NSInteger)number
				  teamName:(NSString*)teamName;

@property (readonly) NSInteger playerNumber;
@property (readonly) NSString* playerTeamName;

@end
