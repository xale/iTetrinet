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
		  forKey:(iTetKeyNamePair*)key
{
	[[NSMutableDictionary cacheDictionary] setObject:image
											  forKey:key];
}

+ (NSImage*)imageForKey:(iTetKeyNamePair*)key
{
	return [[NSMutableDictionary cacheDictionary] objectForKey:key];
}

@end
