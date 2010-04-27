//
//  iTetThemesArrayController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/28/09.
//

#import <Cocoa/Cocoa.h>

@class iTetTheme;

@interface iTetThemesArrayController : NSArrayController

// Additions
- (iTetTheme*)selectedTheme;

// Overrides
- (void)addObject:(id)object;
- (void)removeObjectAtArrangedObjectIndex:(NSUInteger)index;
- (BOOL)canRemove;

@end
