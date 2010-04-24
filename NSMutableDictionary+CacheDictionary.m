//
//  NSMutableDictionary+CacheDictionary.m
//
//  Created by Alex Heinz on 1/19/09.
//

#import "NSMutableDictionary+CacheDictionary.h"

@interface NSMutableDictionary (CacheDictionaryPrivate)

- (void)cleanupCache:(NSNotification*)n;

@end

@implementation NSMutableDictionary (CacheDictionary)

+ (id)cacheDictionary
{
	NSMutableDictionary* cacheDict = [[NSMutableDictionary alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:cacheDict
											 selector:@selector(cleanupCache:)
												 name:NSApplicationWillTerminateNotification
											   object:NSApp];
	return cacheDict;
}

- (void)cleanupCache:(NSNotification*)n
{	
	[self release];
}

@end
