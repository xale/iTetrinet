//
//  iTetChannelListQueryMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetChannelListQueryMessage : iTetMessage <iTetOutgoingMessage>

+ (id)message;

@end
