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
									   encoding:NSUTF8StringEncoding];
	if (utf8String != nil)
		return utf8String;
	
	// If that fails, decode the string as ISO-8859-1
	return [self stringWithData:messageData
					   encoding:NSISOLatin1StringEncoding];
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
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end
