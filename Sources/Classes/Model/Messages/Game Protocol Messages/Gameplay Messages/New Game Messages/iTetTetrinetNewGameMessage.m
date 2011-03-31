//
//  iTetTetrinetNewGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetTetrinetNewGameMessage.h"

NSString* const iTetTetrinetNewGameMessageTag =	@"newgame";

@implementation iTetTetrinetNewGameMessage

#pragma mark -
#pragma mark Accessors

- (NSString*)messageTag
{
	return iTetTetrinetNewGameMessageTag;
}

@end
