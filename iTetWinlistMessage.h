//
//  iTetWinlistMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@interface iTetWinlistMessage : iTetMessage <iTetIncomingMessage>
{
	NSArray* winlistTokens;
}

@property (readonly) NSArray* winlistTokens;

@end
