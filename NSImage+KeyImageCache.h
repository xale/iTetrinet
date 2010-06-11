//
//  NSImage+KeyImageCache.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/21/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetKeyNamePair;

@interface NSImage (KeyImageCache)

+ (void)setImage:(NSImage*)image
		  forKey:(iTetKeyNamePair*)keyName;
+ (NSImage*)imageForKey:(iTetKeyNamePair*)key;

@end
