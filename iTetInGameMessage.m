//
//  iTetInGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetInGameMessage.h"

@implementation iTetInGameMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = inGameMessage;
	
	return self;
}

@end
