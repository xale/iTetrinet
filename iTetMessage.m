//
//  iTetMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/2/10.
//

#import "iTetMessage.h"

@implementation iTetMessage

+ (id)messageFromData:(NSData*)messageData
{
	// FIXME: WRITEME
	
	return nil;
}

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

#pragma mark -
#pragma mark Accessors

@synthesize messageType;

@end
