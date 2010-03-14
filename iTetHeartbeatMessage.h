//
//  iTetHeartbeatMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetMessage.h"

@interface iTetHeartbeatMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>

+ (id)message;

@end
