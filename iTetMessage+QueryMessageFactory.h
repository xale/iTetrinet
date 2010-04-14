//
//  iTetMessage+QueryMessageFactory.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"
#import "iTetChannelListEntryMessage.h"
#import "iTetPlayerListEntryMessage.h"
#import "iTetQueryResponseTerminatorMessage.h"

@interface iTetMessage (QueryMessageFactory)

+ (iTetMessage<iTetIncomingMessage>*)queryMessageFromData:(NSData*)messageData;

@end
