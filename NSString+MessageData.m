//
//  NSString+MessageData.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "NSString+MessageData.h"

@implementation NSString (MessageData)

+ (id)stringWithMessageData:(NSData*)data
{
	return [[[self alloc] initWithBytes:[data bytes]
								 length:[data length]
							   encoding:NSUTF8StringEncoding] autorelease];
}

- (NSData*)messageData
{
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end
