//
//  IPSCacheDictionary.m
//
//  Created by Alex Heinz on 1/19/09.
//

#import "IPSCacheDictionary.h"

static NSMutableDictionary *cache = nil;

@implementation NSMutableDictionary (IPSCacheDictionary)

+ (id)cacheDictionary
{
	@synchronized(self)
	{
		if (cache == nil)
		{
			cache = [[NSMutableDictionary alloc] init];
			
			[[NSNotificationCenter defaultCenter] addObserver:cache
													 selector:@selector(cleanupCache:)
														 name:NSApplicationWillTerminateNotification
													   object:NSApp];
		}
	}
	
	return cache;
}

- (void)cleanupCache:(NSNotification *)n
{	
	[cache release];
	cache = nil;
}

@end
