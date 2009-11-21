//
//  NSImage+KeyImageCache.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/21/09.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (KeyImageCache)

+ (void)setImage:(NSImage*)image
	forKeyName:(NSString*)keyName;
+ (NSImage*)imageForKeyName:(NSString*)keyName;

@end
