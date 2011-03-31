//
//  iTetTetrifastNewGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetTetrifastNewGameMessage.h"

NSString* const iTetTetrifastNewGameMessageTag =	@"*******";

@implementation iTetTetrifastNewGameMessage

#pragma mark -
#pragma mark Accessors

- (NSString*)messageTag
{
	return iTetTetrifastNewGameMessageTag;
}

@end
