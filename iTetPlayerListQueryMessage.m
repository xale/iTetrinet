//
//  iTetPlayerListQueryMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/13/10.
//

#import "iTetPlayerListQueryMessage.h"
#import "NSString+MessageData.h"

@implementation iTetPlayerListQueryMessage

+ (id)message
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	messageType = playerListQueryMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlayerListQueryMessageFormat =	@"listuser";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithString:iTetPlayerListQueryMessageFormat];
	
	return [rawMessage messageData];
}

@end
