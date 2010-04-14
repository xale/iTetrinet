//
//  iTetPlayerListQueryMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/13/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetPlayerListQueryMessage : iTetMessage <iTetOutgoingMessage>

+ (id)message;

@end
