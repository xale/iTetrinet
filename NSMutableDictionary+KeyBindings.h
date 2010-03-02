//
//  NSMutableDictionary+KeyBindings.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/5/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetKeyActions.h"

@class iTetKeyNamePair;

extern NSString* const iTetKeyConfigurationNameKey;

@interface NSMutableDictionary (KeyBindings)

+ (NSMutableArray*)defaultKeyConfigurations;
+ (NSMutableDictionary*)keyConfigurationDictionary;
+ (NSMutableDictionary*)specialTargetsDictionary;

- (void)setAction:(iTetGameAction)action
		   forKey:(iTetKeyNamePair*)key;
- (iTetGameAction)actionForKey:(iTetKeyNamePair*)key;
- (iTetKeyNamePair*)keyForAction:(iTetGameAction)action;

@property (readwrite, retain) NSString* configurationName;

@end
