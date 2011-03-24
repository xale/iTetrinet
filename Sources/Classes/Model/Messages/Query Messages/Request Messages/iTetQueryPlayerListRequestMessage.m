//
//  iTetQueryPlayerListRequestMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/19/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetQueryPlayerListRequestMessage.h"

NSString* const iTetPlayerListQueryMessageContents =	@"listuser";

@implementation iTetQueryPlayerListRequestMessage

- (NSString*)messageContents
{
	return iTetPlayerListQueryMessageContents;
}

@end
