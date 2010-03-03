//
//  iTetClientInfoReplyMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetClientInfoReplyMessage.h"

@implementation iTetClientInfoReplyMessage

+ (id)clientInfoReplyMessage
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	messageType = clientInfoReplyMessage;
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetClientInfoReplyMessageFormat	=	@"clientinfo %@ %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetClientInfoReplyMessageFormat, [self clientName], [self clientVersion]];
	
	return [rawMessage dataUsingEncoding:NSASCIIStringEncoding
					allowLossyConversion:YES];
}

#pragma mark -
#pragma mark Accessors

- (NSString*)clientName
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
}

- (NSString*)clientVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
}

@end
