//
//  iTetPreferencesController.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/6/09.
//

#import "iTetPreferencesController.h"
#import "iTetServerInfo.h"
#import "iTetTheme.h"
#import "NSMutableDictionary+KeyBindings.h"

NSString* const iTetConnectionTimeoutKey =		@"connectionTimeout";
NSString* const iTetAutoSwitchChatKey =			@"autoSwitchChat";
NSString* const iTetThemeListPrefKey =			@"themeList";
NSString* const iTetCurrentThemePrefKey =		@"currentTheme";
NSString* const iTetServerListPrefKey =			@"serverList";
NSString* const iTetKeyConfigsPrefKey =			@"keyConfigs";
NSString* const iTetCurrentKeyConfigNumberKey =	@"currentKeyConfigNum";

NSString* const iTetCurrentThemeDidChangeNotification = @"currentThemeDidChange";

static iTetPreferencesController* preferencesController = nil;

@implementation iTetPreferencesController

+ (void)initialize
{
	// Create a "factory settings" defaults dictionary
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	
	[defaults setObject:[NSNumber numberWithDouble:5.0]
				 forKey:iTetConnectionTimeoutKey];
	[defaults setObject:[NSNumber numberWithBool:YES]
				 forKey:iTetAutoSwitchChatKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[iTetTheme defaultThemeList]]
				 forKey:iTetThemeListPrefKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[iTetTheme defaultTheme]]
				 forKey:iTetCurrentThemePrefKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[iTetServerInfo defaultServers]]
				 forKey:iTetServerListPrefKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSMutableDictionary defaultKeyConfigurations]]
				 forKey:iTetKeyConfigsPrefKey];
	[defaults setObject:[NSNumber numberWithInt:0]
				 forKey:iTetCurrentKeyConfigNumberKey];
	
	// Register the defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)init
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSData* prefsData;
	
	// Load the connection timeout
	connectionTimeout = [defaults doubleForKey:iTetConnectionTimeoutKey];
	
	// Load the "auto-switch to chat after game" flag
	autoSwitchChat = [defaults boolForKey:iTetAutoSwitchChatKey];
	
	// Load the list of themes from user defaults
	prefsData = [defaults objectForKey:iTetThemeListPrefKey];
	themeList = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:prefsData]];
	
	// Load the current theme
	prefsData = [defaults objectForKey:iTetCurrentThemePrefKey];
	currentTheme = [[NSKeyedUnarchiver unarchiveObjectWithData:prefsData] retain];
	
	// Check that the theme loaded successfully
	if (currentTheme == nil)
	{
		currentTheme = [[iTetTheme defaultTheme] retain];
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:currentTheme]
					 forKey:iTetCurrentThemePrefKey];
	}
	
	// Load the list of bookmarked servers
	prefsData = [defaults objectForKey:iTetServerListPrefKey];
	serverList = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:prefsData]];
	
	// Start observing all the servers in the serverList
	[self startObservingServersInArray:serverList];
	
	// Load the list of keyboard configurations
	prefsData = [defaults objectForKey:iTetKeyConfigsPrefKey];
	keyConfigurations = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:prefsData]];
	
	// Load the current configuration number
	currentKeyConfigurationNumber = [[defaults objectForKey:iTetCurrentKeyConfigNumberKey] unsignedIntegerValue];
	if (currentKeyConfigurationNumber >= [keyConfigurations count])
		currentKeyConfigurationNumber = 0;
	
	return self;
}

- (void)dealloc
{
	[self stopObservingServersInArray:serverList];
	[serverList release];
	
	[themeList release];
	[currentTheme release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Singleton Methods/Overrides

+ (iTetPreferencesController*)preferencesController
{
	@synchronized(self)
	{
		if (preferencesController == nil)
		{
			[[self alloc] init];
		}
	}
	
	return preferencesController;
}

+ (id)allocWithZone:(NSZone*)zone
{
	@synchronized(self)
	{
		if (preferencesController == nil)
		{
			preferencesController = [super allocWithZone:zone];
			return preferencesController;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return UINT_MAX;
}

- (void)release
{
	// Nothing
}

- (id)autorelease
{
	return self;
}

#pragma mark -
#pragma mark Key/Value Observing

- (void)startObservingObject:(id)object
{
	if ([object isKindOfClass:[iTetServerInfo class]])
	{
		[object addObserver:self
				 forKeyPath:@"serverName"
					options:0
					context:NULL];
		[object addObserver:self
				 forKeyPath:@"address"
					options:0
					context:NULL];
		[object addObserver:self
				 forKeyPath:@"nickname"
					options:0
					context:NULL];
		[object addObserver:self
				 forKeyPath:@"playerTeam"
					options:0
					context:NULL];
		[object addObserver:self
				 forKeyPath:@"protocol"
					options:0
					context:NULL];
	}
}

- (void)stopObservingObject:(id)object
{
	if ([object isKindOfClass:[iTetServerInfo class]])
	{
		[object removeObserver:self
					forKeyPath:@"serverName"];
		[object removeObserver:self
					forKeyPath:@"address"];
		[object removeObserver:self
					forKeyPath:@"nickname"];
		[object removeObserver:self
					forKeyPath:@"playerTeam"];
		[object removeObserver:self
					forKeyPath:@"protocol"];
	}
}

- (void)startObservingServersInArray:(NSArray*)array
{
	NSIndexSet* allIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [array count])];
	
	[array addObserver:self
	toObjectsAtIndexes:allIndexes
			forKeyPath:@"serverName"
			   options:0
			   context:NULL];
	[array addObserver:self
	toObjectsAtIndexes:allIndexes
			forKeyPath:@"address"
			   options:0
			   context:NULL];
	[array addObserver:self
	toObjectsAtIndexes:allIndexes
			forKeyPath:@"nickname"
			   options:0
			   context:NULL];
	[array addObserver:self
	toObjectsAtIndexes:allIndexes
			forKeyPath:@"playerTeam"
			   options:0
			   context:NULL];
	[array addObserver:self
	toObjectsAtIndexes:allIndexes
			forKeyPath:@"protocol"
			   options:0
			   context:NULL];
}

- (void)stopObservingServersInArray:(NSArray*)array
{
	NSIndexSet* allIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [array count])];
	
	[array removeObserver:self
	 fromObjectsAtIndexes:allIndexes
			   forKeyPath:@"serverName"];
	[array removeObserver:self
	 fromObjectsAtIndexes:allIndexes
			   forKeyPath:@"address"];
	[array removeObserver:self
	 fromObjectsAtIndexes:allIndexes
			   forKeyPath:@"nickame"];
	[array removeObserver:self
	 fromObjectsAtIndexes:allIndexes
			   forKeyPath:@"playerTeam"];
	[array removeObserver:self
	 fromObjectsAtIndexes:allIndexes
			   forKeyPath:@"protocol"];
}

- (void)observeValueForKeyPath:(NSString*)path
					  ofObject:(id)object
						change:(NSDictionary*)change
					   context:(void*)context
{
	if ([object isKindOfClass:[iTetServerInfo class]])
	{
		// We've recieved notification of a change to a ServerInfo object;
		// Write the change to NSUserDefaults
		// FIXME: there should be a faster way than re-archiving the entire array
		[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:serverList]
												  forKey:iTetServerListPrefKey];
	}
}

#pragma mark -
#pragma mark Accessors

#pragma mark Connection Timeout

- (void)setConnectionTimeout:(NSTimeInterval)timeout
{
	// Change the timeout interval
	connectionTimeout = timeout;
	
	// Update the value in user defaults
	[[NSUserDefaults standardUserDefaults] setDouble:timeout
											  forKey:iTetConnectionTimeoutKey];
}
@synthesize connectionTimeout;

#pragma mark Chat Auto-Switch After Game

- (void)setAutoSwitchChat:(BOOL)switchAfterGame
{
	autoSwitchChat = switchAfterGame;
	
	// Update the value in user defaults
	[[NSUserDefaults standardUserDefaults] setBool:switchAfterGame
											forKey:iTetAutoSwitchChatKey];
}
@synthesize autoSwitchChat;

#pragma mark Servers

- (NSUInteger)countOfServerList
{
	return [serverList count];
}

- (iTetServerInfo*)objectInServerListAtIndex:(NSUInteger)index
{
	return [serverList objectAtIndex:index];
}

- (void)insertObject:(iTetServerInfo*)object
 inServerListAtIndex:(NSUInteger)index
{
	// Insert (and begin observing) the new server info
	[serverList insertObject:object
					 atIndex:index];
	[self startObservingObject:object];
	
	// Update the list in user defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:serverList]
											  forKey:iTetServerListPrefKey];
}

- (void)removeObjectFromServerListAtIndex:(NSUInteger)index
{	
	// Stop observing and release the server info
	[self stopObservingObject:[serverList objectAtIndex:index]];
	[serverList removeObjectAtIndex:index];
	
	// Update the list in user defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:serverList]
											  forKey:iTetServerListPrefKey];
}

- (void)setServerList:(NSMutableArray*)servers
{
	// Stop observing all objects in the old list
	[self stopObservingServersInArray:serverList];
	
	// Retain the new list
	[servers retain];
	
	// Release the old list
	[serverList release];
	
	// Assign the list
	serverList = servers;
	
	// Start observing all objects in the new list
	[self startObservingServersInArray:serverList];
	
	// Write the new list to user defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:serverList]
											  forKey:iTetServerListPrefKey];
}
@synthesize serverList;

#pragma mark Themes
- (void)setThemeList:(NSMutableArray*)themes
{
	// Release the old list
	[themeList release];
	
	// Retain the new list
	themeList = [themes retain];
	
	// Write the new list to User Defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:themeList]
											  forKey:iTetThemeListPrefKey];
}
@synthesize themeList;

- (void)setCurrentTheme:(iTetTheme*)theme
{
	// Release the old theme
	[currentTheme release];
	
	// Retain the new theme
	currentTheme = [theme retain];
	
	// Write the new theme (serialized) to User Defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:theme]
											  forKey:iTetCurrentThemePrefKey];
	
	// Post a notification informing views of the new theme
	[[NSNotificationCenter defaultCenter] postNotificationName:iTetCurrentThemeDidChangeNotification
														object:self];
}
@synthesize currentTheme;

- (void)addKeyConfiguration:(NSMutableDictionary*)config
{
	// Add the configuration to the list
	[keyConfigurations addObject:config];
	
	// Write the list to user defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:keyConfigurations]
											  forKey:iTetKeyConfigsPrefKey];
}
- (void)removeKeyConfigurationAtIndex:(NSUInteger)index
{
	// Remove the configuration
	[keyConfigurations removeObjectAtIndex:index];
	
	// Write the list to user defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:keyConfigurations]
											  forKey:iTetKeyConfigsPrefKey];
}
- (void)replaceKeyConfigurationAtIndex:(NSUInteger)index
				  withKeyConfiguration:(NSMutableDictionary*)config
{
	// Replace the configuration
	[keyConfigurations replaceObjectAtIndex:index
								 withObject:config];
	
	// Write the list to user defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:keyConfigurations]
											  forKey:iTetKeyConfigsPrefKey];
}
@synthesize keyConfigurations;

- (void)setCurrentKeyConfigurationNumber:(NSUInteger)num
{
	// Change the current key configuration number
	currentKeyConfigurationNumber = num;
	
	// Write the change to user defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:num]
											  forKey:iTetCurrentKeyConfigNumberKey];
}
@synthesize currentKeyConfigurationNumber;

- (NSMutableDictionary*)currentKeyConfiguration
{
	return [[self keyConfigurations] objectAtIndex:[self currentKeyConfigurationNumber]];
}

@end
