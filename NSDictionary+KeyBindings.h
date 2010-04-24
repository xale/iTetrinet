//
//  NSDictionary+KeyBindings.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/5/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetKeyActions.h"

@class iTetKeyNamePair;

@interface NSDictionary (KeyBindings)

+ (NSDictionary*)currentKeyConfiguration;

- (iTetGameAction)actionForKey:(iTetKeyNamePair*)key;
- (iTetKeyNamePair*)keyForAction:(iTetGameAction)action;

- (NSString*)configurationName;

@end

@interface NSMutableDictionary (KeyBindings)

+ (NSMutableDictionary*)currentKeyConfiguration;
+ (NSMutableArray*)defaultKeyConfigurations;

- (void)setAction:(iTetGameAction)action
		   forKey:(iTetKeyNamePair*)key;
- (void)setConfigurationName:(NSString*)newName;

@end
