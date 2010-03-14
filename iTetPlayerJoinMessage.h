//
//  iTetPlayerJoinMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetMessage.h"

@interface iTetPlayerJoinMessage : iTetMessage <iTetIncomingMessage>
{
	NSInteger playerNumber;
	NSString* nickname;
}

@property (readonly) NSInteger playerNumber;
@property (readonly) NSString* nickname;

@end
