//
//  iTetClientInfoMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetClientInfoMessage.h"

@implementation iTetClientInfoMessage

- (id)init
{
	// Needs to be overridden, despite the fact that init does nothing, because the superclass is abstract, and its init implementation calls doesNotRespondToSelector:
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetClientInfoMessageFormat	=	@"clientinfo %@ %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetClientInfoMessageFormat, [self clientName], [self clientVersion]];
	
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
