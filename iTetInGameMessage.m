//
//  iTetInGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
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
