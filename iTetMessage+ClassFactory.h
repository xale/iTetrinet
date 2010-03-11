//
//  iTetMessage+ClassFactory.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/10/10.
//

#import "iTetMessage.h"

@interface iTetMessage (ClassFactory)

+ (iTetMessage<iTetIncomingMessage>*)messageFromData:(NSData*)data;

@end
