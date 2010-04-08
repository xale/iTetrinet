//
//  iTetChannelListQueryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/7/10.
//

#import "iTetChannelListQueryMessage.h"

@implementation iTetChannelListQueryMessage

+ (id)message
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	messageType = channelListQueryMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetChannelListQueryMessageFormat =	@"listchan";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithString:iTetChannelListQueryMessageFormat];
	
	return [rawMessage messageData];
}

@end
