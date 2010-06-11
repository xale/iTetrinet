//
//  iTetNewGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/4/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@interface iTetNewGameMessage : iTetMessage <iTetIncomingMessage>
{
	NSArray* rulesList;
}

@property (readonly) NSArray* rulesList;

@end
