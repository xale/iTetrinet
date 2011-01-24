//
//  NSUserDefaults+AdditionalTypes.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/23/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface NSUserDefaults (AdditionalTypes)

- (void)archiveAndSetObject:(id)object
					 forKey:(NSString*)key;
- (id)unarchivedObjectForKey:(NSString*)key;

- (void)setUnsignedInteger:(NSUInteger)value
					forKey:(NSString*)key;
- (NSUInteger)unsignedIntegerForKey:(NSString*)key;

@end
