//
//  iTetClientInfoReplyMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetClientInfoReplyMessage : iTetMessage <iTetOutgoingMessage>

+ (id)message;

@property (readonly) NSString* clientName;
@property (readonly) NSString* clientVersion;

@end
