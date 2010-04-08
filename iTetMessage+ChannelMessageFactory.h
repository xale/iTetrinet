//
//  iTetMessage+ChannelMessageFactory.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"
#import "iTetChannelListEntryMessage.h"
#import "iTetQueryResponseTerminatorMessage.h"

@interface iTetMessage (ChannelMessageFactory)

+ (iTetMessage<iTetIncomingMessage>*)channelMessageFromData:(NSData*)messageData;

@end
