//
//  iTetNoPayloadMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNoPayloadMessage.h"

@implementation iTetNoPayloadMessage

+ (id)message
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	// Overrides superclass' abstract initializer
	return self;
}

- (id)initWithMessageTokens:(NSArray*)tokens
{
	// Overrides superclass' abstract initializer
	// Ignore message data
	return self;
}

@end
