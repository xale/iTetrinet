//
//  IPSCacheDictionary.h
//
//  Created by Alex Heinz on 1/19/09.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableDictionary (IPSCacheDictionary)

+ (id)cacheDictionary;

- (void)cleanupCache:(NSNotification *)n;

@end
