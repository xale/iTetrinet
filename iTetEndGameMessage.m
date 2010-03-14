//
//  iTetEndGameMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/7/10.
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
