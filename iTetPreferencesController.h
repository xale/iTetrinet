//
//  iTetPreferencesController.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/6/09.
//

#import <Cocoa/Cocoa.h>

@class iTetTheme;
@class iTetServerInfo;

extern NSString* const iTetThemeListPrefKey;
extern NSString* const iTetCurrentThemePrefKey;
extern NSString* const iTetServerListPrefKey;
extern NSString* const iTetKeyConfigsPrefKey;
extern NSString* const iTetCurrentKeyConfigNumberKey;

extern NSString* const iTetCurrentThemeDidChangeNotification;

@interface iTetPreferencesController : NSObject
{
	NSTimeInterval connectionTimeout;
	
	BOOL autoSwitchChat;
	
	NSMutableArray* serverList;
	
	NSMutableArray* themeList;
	iTetTheme* currentTheme;
	
	NSMutableArray* keyConfigurations;
	NSUInteger currentKeyConfigurationNumber;
}

+ (iTetPreferencesController*)preferencesController;

@property (readwrite, assign) NSTimeInterval connectionTimeout;
@property (readwrite, assign) BOOL autoSwitchChat;
@property (readwrite, retain) NSMutableArray* serverList;
@property (readwrite, retain) NSMutableArray* themeList;
@property (readwrite, retain) iTetTheme* currentTheme;

- (void)addKeyConfiguration:(NSMutableDictionary*)config;
- (void)removeKeyConfigurationAtIndex:(NSUInteger)index;
- (void)replaceKeyConfigurationAtIndex:(NSUInteger)index
				  withKeyConfiguration:(NSMutableDictionary*)config;
@property (readwrite, retain) NSMutableArray* keyConfigurations;
@property (readwrite, assign) NSUInteger currentKeyConfigurationNumber;
- (NSMutableDictionary*)currentKeyConfiguration;

@end
