//
//  iTetEndGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetEndGameMessage.h"

@implementation iTetEndGameMessage

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializers

+ (id)messageWithMessageData:(NSData*)messageData
{
	return [[[self alloc] initWithMessageData:messageData] autorelease];
}

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = endGameMessage;
	
	return self;
}

@end
