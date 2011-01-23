//
//  NSMutableDictionary+CacheDictionary.m
//
//  Created by Alex Heinz on 1/19/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
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
