//
//  iTetPartylineActionMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/27/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPartylineActionMessage.h"

NSString* const iTetPartylineActionMessageTag =	@"plineact";

@implementation iTetPartylineActionMessage

#pragma mark -
#pragma mark Accessors

- (NSString*)messageTag
{
	return iTetPartylineActionMessageTag;
}

@end
