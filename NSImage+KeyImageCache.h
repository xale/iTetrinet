//
//  NSImage+KeyImageCache.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/21/09.
//

#import <Cocoa/Cocoa.h>

@class iTetKeyNamePair;

@interface NSImage (KeyImageCache)

+ (void)setImage:(NSImage*)image
		  forKey:(iTetKeyNamePair*)keyName;
+ (NSImage*)imageForKey:(iTetKeyNamePair*)key;

@end
