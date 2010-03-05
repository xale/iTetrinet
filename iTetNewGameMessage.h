//
//  iTetNewGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetNewGameMessage : iTetMessage <iTetIncomingMessage>
{
	NSArray* rulesList;
}

@property (readonly) NSArray* rulesList;

@end
