//
//  NSImage+KeyImageCache.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/21/09.
//

#import "NSImage+KeyImageCache.h"
#import "IPSCacheDictionary.h"

@implementation NSImage (KeyImageCache)

+ (void)setImage:(NSImage*)image
	  forKeyName:(NSString*)keyName
{
	[[NSMutableDictionary cacheDictionary] setObject:image
											  forKey:keyName];
}

+ (NSImage*)imageForKeyName:(NSString*)keyName
{
	return [[NSMutableDictionary cacheDictionary] objectForKey:keyName];
}

@end
