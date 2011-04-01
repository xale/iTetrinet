//
//  iTetEndGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetEndGameMessage.h"

NSString* const iTetEndGameMessageTag =	@"endgame";

@implementation iTetEndGameMessage

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return iTetEndGameMessageTag;
}

@end
