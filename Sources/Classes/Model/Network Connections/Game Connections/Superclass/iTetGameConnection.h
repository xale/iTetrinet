//
//  iTetGameConnection.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/17/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNetworkConnection.h"

@interface iTetGameConnection : iTetNetworkConnection

/*!
 @warning Abstract method; subclasses must override.
 Returns a dictionary mapping message tags to their corresponding iTetMessage subclass.
 @return An NSDictionary instance mapping NSString -> Class.
 */
- (NSDictionary*)messageTypesByTag;

@end
