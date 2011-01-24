//
//  NSDictionary+AdditionalTypes.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/26/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface NSDictionary (AdditionalTypes)

- (BOOL)boolForKey:(NSString*)key;
- (int)intForKey:(NSString*)key;
- (NSInteger)integerForKey:(NSString*)key;
- (NSUInteger)unsignedIntegerForKey:(NSString*)key;

@end

@interface NSMutableDictionary (AdditionalTypes)

- (void)setBool:(BOOL)value
		 forKey:(NSString*)key;
- (void)setInt:(int)value
		forKey:(NSString*)key;
- (void)setInteger:(NSInteger)value
			forKey:(NSString*)key;
- (void)setUnsignedInteger:(NSUInteger)value
					forKey:(NSString*)key;

@end
