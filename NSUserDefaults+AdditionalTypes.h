//
//  NSUserDefaults+AdditionalTypes.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/23/10.
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
