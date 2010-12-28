//
//  NSDictionary+AdditionalTypes.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/26/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "NSDictionary+AdditionalTypes.h"

@implementation NSDictionary (AdditionalTypes)

- (BOOL)boolForKey:(NSString*)key
{
	return [[self objectForKey:key] boolValue];
}

- (int)intForKey:(NSString*)key
{
	return [[self objectForKey:key] intValue];
}

- (NSInteger)integerForKey:(NSString*)key
{
	return [[self objectForKey:key] integerValue];
}

- (NSUInteger)unsignedIntegerForKey:(NSString*)key
{
	return [[self objectForKey:key] unsignedIntegerValue];
}

@end

@implementation NSMutableDictionary (AdditionalTypes)

- (void)setBool:(BOOL)value
		 forKey:(NSString*)key
{
	[self setObject:[NSNumber numberWithBool:value]
			 forKey:key];
}

- (void)setInt:(int)value
		forKey:(NSString*)key
{
	[self setObject:[NSNumber numberWithInt:value]
			 forKey:key];
}

- (void)setInteger:(NSInteger)value
			forKey:(NSString*)key
{
	[self setObject:[NSNumber numberWithInteger:value]
			 forKey:key];
}

- (void)setUnsignedInteger:(NSUInteger)value
					forKey:(NSString*)key
{
	[self setObject:[NSNumber numberWithUnsignedInteger:value]
			 forKey:key];
}

@end
