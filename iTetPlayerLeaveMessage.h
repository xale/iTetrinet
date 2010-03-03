//
//  iTetPlayerLeaveMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetPlayerLeaveMessage : iTetMessage <iTetIncomingMessage>
{
	NSInteger playerNumber;
}

@property (readonly) NSInteger playerNumber;

@end
