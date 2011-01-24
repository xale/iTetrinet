//
//  iTetThemesArrayController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/28/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetTheme;

@interface iTetThemesArrayController : NSArrayController

// Additions
- (iTetTheme*)selectedTheme;
- (void)replaceTheme:(iTetTheme*)oldTheme
		   withTheme:(iTetTheme*)newTheme;

// Overrides
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)removeObjectAtArrangedObjectIndex:(NSUInteger)index;
- (BOOL)canRemove;

@end
