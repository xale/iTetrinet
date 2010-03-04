//
//  iTetPlayerTeamMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetPlayerTeamMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	NSInteger playerNumber;
	NSString* teamName;
}

+ (id)messageWithPlayerNumber:(NSInteger)number
					 teamName:(NSString*)nameOfTeam;
- (id)initWithPlayerNumber:(NSInteger)number
				  teamName:(NSString*)nameOfTeam;

@property (readonly) NSInteger playerNumber;
@property (readonly) NSString* teamName;

@end
