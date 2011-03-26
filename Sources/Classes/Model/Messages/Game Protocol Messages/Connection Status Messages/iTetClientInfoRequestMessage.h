//
//  iTetClientInfoRequestMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNoPayloadMessage.h"

// NOTE: the client-info-request message does not have a unique tag, instead taking the form of a level-update message: "lvl 0 0"
// As a result, instances of this class will be silently instantiated by the iTetPlayerLevelMessage initializer.

@interface iTetClientInfoRequestMessage : iTetNoPayloadMessage

@end
