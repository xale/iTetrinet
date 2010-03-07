//
//  iTetPlayerTeamMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetMessage.h"

@class iTetPlayer;

@interface iTetPlayerTeamMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSInteger playerNumber;
	NSString* teamName;
}

+ (id)messageForPlayer:(iTetPlayer*)player;
- (id)initWithPlayerNumber:(NSInteger)number
				  teamName:(NSString*)nameOfTeam;

@property (readonly) NSInteger playerNumber;
@property (readonly) NSString* teamName;

@end
