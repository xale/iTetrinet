//
//  NSString+MessageData.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "NSString+MessageData.h"

@implementation NSString (MessageData)

+ (id)stringWithMessageData:(NSData*)messageData
{
	// First, attempt to interpret the string as UTF-8
	NSString* utf8String = [self stringWithData:messageData
									   encoding:iTetDefaultStringEncoding];
	if (utf8String != nil)
		return utf8String;
	
	// If that fails, decode the string as Windows-1252
	return [self stringWithData:messageData
					   encoding:iTetFallbackStringEncoding];
}

+ (id)stringWithData:(NSData*)data
			encoding:(NSStringEncoding)encoding
{
	return [[[self alloc] initWithBytes:[data bytes]
								 length:[data length]
							   encoding:encoding] autorelease];
}

- (NSData*)messageData
{
	return [self dataUsingEncoding:iTetDefaultStringEncoding];
}

@end
