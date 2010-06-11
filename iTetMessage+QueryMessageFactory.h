//
//  iTetMessage+QueryMessageFactory.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"
#import "iTetChannelListEntryMessage.h"
#import "iTetPlayerListEntryMessage.h"
#import "iTetQueryResponseTerminatorMessage.h"

@interface iTetMessage (QueryMessageFactory)

+ (iTetMessage<iTetIncomingMessage>*)queryMessageFromData:(NSData*)messageData;

@end
