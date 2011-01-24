//
//  iTetPlayer+GameEvents.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/15/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetPlayer.h"

@interface iTetPlayer (GameEvents)

- (NSAttributedString*)senderEventDescriptionNickname;
- (NSAttributedString*)targetEventDescriptionNickname;

@end
