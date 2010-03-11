//
//  iTetPlayerWonMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/10/10.
//

#import "iTetMessage.h"

@interface iTetPlayerWonMessage : iTetMessage <iTetIncomingMessage>
{
	NSInteger playerNumber;
}

@property (readonly) NSInteger playerNumber;

@end
