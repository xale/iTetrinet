//
//  iTetGrowlController.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/18/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetGrowlController.h"
#import "iTetPlayer.h"

static iTetGrowlController* sharedController = nil;

NSString* const iTetPlayerJoinedGrowlNotificationName =			@"com.indiepennant.iTetrinet.playerJoinedGrowlNotification";
NSString* const iTetPlayerLeftGrowlNotificationName =			@"com.indiepennant.iTetrinet.playerLeftGrowlNotification";
NSString* const iTetPlayerChangedTeamGrowlNotificationName =	@"com.indiepennant.iTetrinet.playerChangedTeamGrowlNotification";
// FIXME: WRITEME: more notification types

@interface iTetGrowlController (Private)

- (NSArray*)allNotificationNames;
- (NSDictionary*)humanReadableNotificationNames;
- (NSDictionary*)notificationDescriptions;

@end

@implementation iTetGrowlController

#pragma mark -
#pragma mark Singleton Overrides

+ (iTetGrowlController*)sharedGrowlController
{
	@synchronized (self)
	{
		if (sharedController == nil)
		{
			[[self alloc] init];
		}
	}
	
	return sharedController;
}

+ (id)allocWithZone:(NSZone*)zone
{
	@synchronized(self)
	{
		if (sharedController == nil)
		{
			sharedController = [super allocWithZone:zone];
			return sharedController;
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
	// Does nothing
}

- (id)autorelease
{
	return self;
}

#pragma mark -
#pragma mark Growl Registration

- (NSDictionary*)registrationDictionaryForGrowl
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[self allNotificationNames], GROWL_NOTIFICATIONS_ALL,
			[self allNotificationNames], GROWL_NOTIFICATIONS_DEFAULT,
			[self humanReadableNotificationNames], GROWL_NOTIFICATIONS_HUMAN_READABLE_NAMES,
			[self notificationDescriptions], GROWL_NOTIFICATIONS_DESCRIPTIONS,
			nil];
			
}

- (NSArray*)allNotificationNames
{
	return [NSArray arrayWithObjects:
			iTetPlayerJoinedGrowlNotificationName,
			iTetPlayerLeftGrowlNotificationName,
			iTetPlayerChangedTeamGrowlNotificationName,
			nil];
}

#define iTetPlayerJoinedGrowlNotificationHumanReadableName		NSLocalizedStringFromTable(@"Player Joined Channel", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when a new player joins the local player's channel")
#define iTetPlayerLeftGrowlNotificationHumanReadableName		NSLocalizedStringFromTable(@"Player Left Channel", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when another player leaves the local player's channel")
#define iTetPlayerChangedTeamGrowlNotificationHumanReadableName	NSLocalizedStringFromTable(@"Player Changed Team", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when a player in the local player's channel changes his or her team")
// FIXME: WRITEME: more notification types

- (NSDictionary*)humanReadableNotificationNames
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			iTetPlayerJoinedGrowlNotificationHumanReadableName, iTetPlayerJoinedGrowlNotificationName,
			iTetPlayerLeftGrowlNotificationHumanReadableName, iTetPlayerLeftGrowlNotificationName,
			iTetPlayerChangedTeamGrowlNotificationHumanReadableName, iTetPlayerChangedTeamGrowlNotificationName,
			nil];
}

#define iTetPlayerJoinedGrowlNotificationPreferencesDescription			NSLocalizedStringFromTable(@"When a new player joins your channel", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player joined' notification will be displayed")
#define iTetPlayerLeftGrowlNotificationPreferencesDescription			NSLocalizedStringFromTable(@"When a player leaves your channel", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player left' notification will be displayed")
#define iTetPlayerChangedTeamGrowlNotificationPreferencesDescription	NSLocalizedStringFromTable(@"When a player in your channel changes teams", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player changed team' notification will be displayed")
// FIXME: WRITEME: more notification types

- (NSDictionary*)notificationDescriptions
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			iTetPlayerJoinedGrowlNotificationPreferencesDescription, iTetPlayerJoinedGrowlNotificationName,
			iTetPlayerLeftGrowlNotificationPreferencesDescription, iTetPlayerLeftGrowlNotificationName,
			iTetPlayerChangedTeamGrowlNotificationPreferencesDescription, iTetPlayerChangedTeamGrowlNotificationName,
			nil];
}

- (NSString*)applicationNameForGrowl
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
}

#pragma mark -
#pragma mark Notifications

#define iTetPlayerJoinedGrowlNotificationTitle			NSLocalizedStringFromTable(@"Player Joined Channel", @"GrowlController", @"Title (first line) of the Growl notification displayed when a new player joins the local player's channel")
#define iTetPlayerJoinedGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has joined the channel", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a new player joins the local player's channel")

- (void)postJoinNotificationForPlayer:(iTetPlayer*)player
{
	[GrowlApplicationBridge notifyWithTitle:iTetPlayerJoinedGrowlNotificationTitle
								description:[NSString stringWithFormat:iTetPlayerJoinedGrowlNotificationMessageFormat, [player nickname]]
						   notificationName:iTetPlayerJoinedGrowlNotificationName
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

#define iTetPlayerLeftGrowlNotificationTitle			NSLocalizedStringFromTable(@"Player Left Channel", @"GrowlController", @"Title (first line) of the Growl notification displayed when another player leaves the local player's channel")
#define iTetPlayerLeftGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has left the channel", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when another player leaves the local player's channel")

- (void)postLeaveNotificationForPlayer:(iTetPlayer*)player
{
	[GrowlApplicationBridge notifyWithTitle:iTetPlayerLeftGrowlNotificationTitle
								description:[NSString stringWithFormat:iTetPlayerLeftGrowlNotificationMessageFormat, [player nickname]]
						   notificationName:iTetPlayerLeftGrowlNotificationName
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

#define iTetPlayerChangedTeamGrowlNotificationTitle			NSLocalizedStringFromTable(@"Player Changed Team", @"GrowlController", @"Title (first line) of the Growl notification displayed when a player in the local player's channel changes his or her team")
#define iTetPlayerJoinedTeamGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has joined team '%@'", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a player in the local player's channel joins a team")
#define iTetPlayerLeftTeamGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has left team '%@'", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a player in the local player's channel leaves his or her team")

- (void)postTeamChangeNotificationForPlayer:(iTetPlayer*)player
{
	// FIXME: handle "left team" events
	[GrowlApplicationBridge notifyWithTitle:iTetPlayerChangedTeamGrowlNotificationTitle
								description:[NSString stringWithFormat:iTetPlayerJoinedTeamGrowlNotificationMessageFormat, [player nickname], [player teamName]]
						   notificationName:iTetPlayerChangedTeamGrowlNotificationName
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

@end
