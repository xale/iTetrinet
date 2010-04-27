//
//  iTetKeyConfiguration.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/5/09.
//

#import <Cocoa/Cocoa.h>
#import "iTetKeyActions.h"

@class iTetKeyNamePair;

@interface iTetKeyConfiguration : NSObject <NSCopying, NSCoding>
{
	NSString* configurationName;
	NSMutableDictionary* keyBindings;
}

+ (iTetKeyConfiguration*)currentKeyConfiguration;
+ (NSMutableArray*)defaultKeyConfigurations;
+ (id)keyConfiguration;
+ (id)keyConfigurationWithName:(NSString*)configName;
- (id)initWithConfigurationName:(NSString*)configName;

@property (readwrite, copy) NSString* configurationName;
- (iTetGameAction)actionForKeyBinding:(iTetKeyNamePair*)key;
- (iTetKeyNamePair*)keyBindingForAction:(iTetGameAction)action;
- (void)setAction:(iTetGameAction)action
	forKeyBinding:(iTetKeyNamePair*)key;

@end
