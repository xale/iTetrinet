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
#import "iTetNotifications.h"

static iTetGrowlController* sharedController = nil;

NSString* const iTetPlayerJoinedGrowlNotificationName =			@"com.indiepennant.iTetrinet.playerJoinedGrowlNotification";
NSString* const iTetPlayerLeftGrowlNotificationName =			@"com.indiepennant.iTetrinet.playerLeftGrowlNotification";
NSString* const iTetPlayerTeamChangedGrowlNotificationName =	@"com.indiepennant.iTetrinet.playerTeamChangedGrowlNotification";
// FIXME: WRITEME: more notification types

@interface iTetGrowlController (Private)

- (NSArray*)allNotificationNames;
- (NSDictionary*)humanReadableNotificationNames;
- (NSDictionary*)notificationDescriptions;

@end

@implementation iTetGrowlController

- (id)init
{
	// Register for player-event notifications
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	
	// Player joined
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerJoinedEventNotificationName
			 object:nil];
	
	// Player left
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerLeftEventNotificationName
			 object:nil];
	
	// Player changed team
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerTeamChangeEventNotificationName
			 object:nil];
	
	return self;
}

- (void)dealloc
{
	// De-register for player-event notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

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
			iTetPlayerTeamChangedGrowlNotificationName,
			nil];
}

#define iTetPlayerJoinedGrowlNotificationHumanReadableName		NSLocalizedStringFromTable(@"Player Joined Channel", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when a new player joins the local player's channel")
#define iTetPlayerLeftGrowlNotificationHumanReadableName		NSLocalizedStringFromTable(@"Player Left Channel", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when another player leaves the local player's channel")
#define iTetPlayerTeamChangedGrowlNotificationHumanReadableName	NSLocalizedStringFromTable(@"Player Changed Team", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when a player in the local player's channel changes his or her team")
// FIXME: WRITEME: more notification types

- (NSDictionary*)humanReadableNotificationNames
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			iTetPlayerJoinedGrowlNotificationHumanReadableName, iTetPlayerJoinedGrowlNotificationName,
			iTetPlayerLeftGrowlNotificationHumanReadableName, iTetPlayerLeftGrowlNotificationName,
			iTetPlayerTeamChangedGrowlNotificationHumanReadableName, iTetPlayerTeamChangedGrowlNotificationName,
			nil];
}

#define iTetPlayerJoinedGrowlNotificationPreferencesDescription			NSLocalizedStringFromTable(@"When a new player joins your channel", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player joined' notification will be displayed")
#define iTetPlayerLeftGrowlNotificationPreferencesDescription			NSLocalizedStringFromTable(@"When a player leaves your channel", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player left' notification will be displayed")
#define iTetPlayerTeamChangedGrowlNotificationPreferencesDescription	NSLocalizedStringFromTable(@"When a player in your channel changes teams", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player changed team' notification will be displayed")
// FIXME: WRITEME: more notification types

- (NSDictionary*)notificationDescriptions
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			iTetPlayerJoinedGrowlNotificationPreferencesDescription, iTetPlayerJoinedGrowlNotificationName,
			iTetPlayerLeftGrowlNotificationPreferencesDescription, iTetPlayerLeftGrowlNotificationName,
			iTetPlayerTeamChangedGrowlNotificationPreferencesDescription, iTetPlayerTeamChangedGrowlNotificationName,
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

#define iTetPlayerLeftGrowlNotificationTitle			NSLocalizedStringFromTable(@"Player Left Channel", @"GrowlController", @"Title (first line) of the Growl notification displayed when another player leaves the local player's channel")
#define iTetPlayerLeftGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has left the channel", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when another player leaves the local player's channel")

#define iTetPlayerTeamChangedGrowlNotificationTitle				NSLocalizedStringFromTable(@"Player Changed Team", @"GrowlController", @"Title (first line) of the Growl notification displayed when a player in the local player's channel changes his or her team")
#define iTetPlayerJoinedTeamGrowlNotificationMessageFormat		NSLocalizedStringFromTable(@"%@ has joined team '%@'", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a player in the local player's channel joins a team")
#define iTetPlayerSwitchedTeamGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has switched to team '%@'", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a player in the local player's channel changes from one team to another")
#define iTetPlayerLeftTeamGrowlNotificationMessageFormat		NSLocalizedStringFromTable(@"%@ has left team '%@'", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a player in the local player's channel leaves his or her team")

- (void)playerEventNotification:(NSNotification*)notification
{
	// Determine the type of event, and append the appropriate status message to the chat view
	NSString* eventType = [notification name];
	NSString* nickname = [[notification userInfo] objectForKey:iTetNotificationPlayerNicknameKey];
	if ([eventType isEqualToString:iTetPlayerJoinedEventNotificationName])
	{
		// Player joined
		[self postGrowlNotificationWithTitle:iTetPlayerJoinedGrowlNotificationTitle
								 description:[NSString stringWithFormat:iTetPlayerJoinedGrowlNotificationMessageFormat, nickname]
							notificationName:iTetPlayerJoinedGrowlNotificationName];
	}
	else if ([eventType isEqualToString:iTetPlayerLeftEventNotificationName])
	{
		// Player left
		[self postGrowlNotificationWithTitle:iTetPlayerLeftGrowlNotificationTitle
								 description:[NSString stringWithFormat:iTetPlayerLeftGrowlNotificationMessageFormat, nickname]
							notificationName:iTetPlayerLeftGrowlNotificationName];
	}
	else if ([eventType isEqualToString:iTetPlayerTeamChangeEventNotificationName])
	{
		// Player team-change
		// Get the new and old team names
		NSString* oldTeamName = [[notification userInfo] objectForKey:iTetNotificationOldTeamNameKey];
		NSString* newTeamName = [[notification userInfo] objectForKey:iTetNotificationNewTeamNameKey];
		
		// Check if the player is joining a team, switching teams, or leaving a team
		if ([oldTeamName length] > 0)
		{
			if ([newTeamName length] > 0)
			{
				[self postGrowlNotificationWithTitle:iTetPlayerTeamChangedGrowlNotificationTitle
										 description:[NSString stringWithFormat:iTetPlayerSwitchedTeamGrowlNotificationMessageFormat, nickname, newTeamName]
									notificationName:iTetPlayerTeamChangedGrowlNotificationName];
			}
			else
			{
				[self postGrowlNotificationWithTitle:iTetPlayerTeamChangedGrowlNotificationTitle
										 description:[NSString stringWithFormat:iTetPlayerLeftTeamGrowlNotificationMessageFormat, nickname, oldTeamName]
									notificationName:iTetPlayerTeamChangedGrowlNotificationName];
			}
		}
		else
		{
			if ([newTeamName length] > 0)
			{
				[self postGrowlNotificationWithTitle:iTetPlayerTeamChangedGrowlNotificationTitle
										 description:[NSString stringWithFormat:iTetPlayerJoinedTeamGrowlNotificationMessageFormat, nickname, newTeamName]
									notificationName:iTetPlayerTeamChangedGrowlNotificationName];
			}
		}
	}
}

- (void)postGrowlNotificationWithTitle:(NSString*)title
						   description:(NSString*)description
					  notificationName:(NSString*)name
{
	[GrowlApplicationBridge notifyWithTitle:title
								description:description
						   notificationName:name
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

@end
