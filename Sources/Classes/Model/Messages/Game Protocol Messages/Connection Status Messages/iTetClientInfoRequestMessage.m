//
//  iTetClientInfoRequestMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetClientInfoRequestMessage.h"
#import "iTetPlayerLevelMessage.h"

@implementation iTetClientInfoRequestMessage

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ 0 0", iTetPlayerLevelMessageTag];
}

@end
