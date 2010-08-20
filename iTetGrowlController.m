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
#import "iTetUserDefaults.h"

#import "NSDictionary+AdditionalTypes.h"

static iTetGrowlController* sharedController = nil;

@interface iTetGrowlController (Private)

- (NSArray*)allNotificationNames;
- (NSDictionary*)humanReadableNotificationNames;
- (NSDictionary*)notificationDescriptions;

@end

@implementation iTetGrowlController

+ (void)initialize
{
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	[defaults setBool:YES
			   forKey:iTetEnableGrowlNotificationsPrefKey];
	[defaults setBool:NO
			   forKey:iTetGrowlBackgroundOnlyPrefKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)init
{
	// Register for event notifications
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
	
	// Player kicked
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerKickedEventNotificationName
			 object:nil];
	
	// Player changed team
	[nc addObserver:self
		   selector:@selector(playerEventNotification:)
			   name:iTetPlayerTeamChangeEventNotificationName
			 object:nil];
	
	// Game ended
	[nc addObserver:self
		   selector:@selector(gameEventNotification:)
			   name:iTetGameEndedEventNotificationName
			 object:nil];
	
	// Player won
	[nc addObserver:self
		   selector:@selector(gameEventNotification:)
			   name:iTetGamePlayerWonEventNotification
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

NSString* const iTetPlayerJoinedGrowlNotificationName =			@"com.indiepennant.iTetrinet.playerJoinedGrowlNotification";
NSString* const iTetPlayerLeftGrowlNotificationName =			@"com.indiepennant.iTetrinet.playerLeftGrowlNotification";
NSString* const iTetPlayerKickedGrowlNotificationName =			@"com.indiepennant.iTetrinet.playerKickedGrowlNotification";
NSString* const iTetPlayerTeamChangedGrowlNotificationName =	@"com.indiepennant.iTetrinet.playerTeamChangedGrowlNotification";
NSString* const iTetGameEndedGrowlNotificationName =			@"com.indiepennant.iTetrinet.gameEndedGrowlNotification";
// FIXME: WRITEME: more notification types

- (NSArray*)allNotificationNames
{
	return [NSArray arrayWithObjects:
			iTetPlayerJoinedGrowlNotificationName,
			iTetPlayerLeftGrowlNotificationName,
			iTetPlayerKickedGrowlNotificationName,
			iTetPlayerTeamChangedGrowlNotificationName,
			iTetGameEndedGrowlNotificationName,
			nil];
}

#define iTetPlayerJoinedGrowlNotificationHumanReadableName		NSLocalizedStringFromTable(@"Player Joined Channel", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when a new player joins the local player's channel")
#define iTetPlayerLeftGrowlNotificationHumanReadableName		NSLocalizedStringFromTable(@"Player Left Channel", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when another player leaves the local player's channel")
#define iTetPlayerKickedGrowlNotificationHumanReadableName		NSLocalizedStringFromTable(@"Player Kicked", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when a player in the local player's channel is kicked from the server")
#define iTetPlayerTeamChangedGrowlNotificationHumanReadableName	NSLocalizedStringFromTable(@"Player Changed Team", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when a player in the local player's channel changes his or her team")
#define iTetGameEndedGrowlNotificationHumanReadableName			NSLocalizedStringFromTable(@"Game Ended", @"GrowlController", @"Name used in Growl System Preferences pane for the notification displayed when a game ends")
// FIXME: WRITEME: more notification types

- (NSDictionary*)humanReadableNotificationNames
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			iTetPlayerJoinedGrowlNotificationHumanReadableName, iTetPlayerJoinedGrowlNotificationName,
			iTetPlayerLeftGrowlNotificationHumanReadableName, iTetPlayerLeftGrowlNotificationName,
			iTetPlayerKickedGrowlNotificationHumanReadableName, iTetPlayerKickedGrowlNotificationName,
			iTetPlayerTeamChangedGrowlNotificationHumanReadableName, iTetPlayerTeamChangedGrowlNotificationName,
			iTetGameEndedGrowlNotificationHumanReadableName, iTetGameEndedGrowlNotificationName,
			nil];
}

#define iTetPlayerJoinedGrowlNotificationPreferencesDescription			NSLocalizedStringFromTable(@"When a new player joins your channel", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player joined' notification will be displayed")
#define iTetPlayerLeftGrowlNotificationPreferencesDescription			NSLocalizedStringFromTable(@"When a player leaves your channel", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player left' notification will be displayed")
#define iTetPlayerKickedGrowlNotificationPreferencesDescription			NSLocalizedStringFromTable(@"When a player in your channel is kicked", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player kicked' notification will be displayed")
#define iTetPlayerTeamChangedGrowlNotificationPreferencesDescription	NSLocalizedStringFromTable(@"When a player in your channel changes teams", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'player changed team' notification will be displayed")
#define iTetGameEndedGrowlNotificationPreferencesDescription			NSLocalizedStringFromTable(@"When a game ends", @"GrowlController", @"Short description used in Growl System Preferences pane to explain when the 'game ended' notification will be displayed")
// FIXME: WRITEME: more notification types

- (NSDictionary*)notificationDescriptions
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			iTetPlayerJoinedGrowlNotificationPreferencesDescription, iTetPlayerJoinedGrowlNotificationName,
			iTetPlayerLeftGrowlNotificationPreferencesDescription, iTetPlayerLeftGrowlNotificationName,
			iTetPlayerKickedGrowlNotificationPreferencesDescription, iTetPlayerKickedGrowlNotificationName,
			iTetPlayerTeamChangedGrowlNotificationPreferencesDescription, iTetPlayerTeamChangedGrowlNotificationName,
			iTetGameEndedGrowlNotificationPreferencesDescription, iTetGameEndedGrowlNotificationName,
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

#define iTetPlayerKickedGrowlNotificationTitle			NSLocalizedStringFromTable(@"Player Kicked", @"GrowlController", @"Title (first line) of the Growl notification displayed when another player in the local player's channel is kicked from the server")
#define iTetPlayerKickedGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has been kicked from the server", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when another player in the local player's channel is kicked from the server")
#define iTetLocalPlayerKickedGrowlNotificationTitle		NSLocalizedStringFromTable(@"Kicked", @"GrowlController", @"Title (first line) of the Growl notification displayed when the local player is kicked from the server")
#define iTetLocalPlayerKickedGrowlNotificationMessage	NSLocalizedStringFromTable(@"You have been kicked from the server", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when the local player is kicked from the server")

#define iTetPlayerTeamChangedGrowlNotificationTitle				NSLocalizedStringFromTable(@"Player Changed Team", @"GrowlController", @"Title (first line) of the Growl notification displayed when a player in the local player's channel changes his or her team")
#define iTetPlayerJoinedTeamGrowlNotificationMessageFormat		NSLocalizedStringFromTable(@"%@ has joined team '%@'", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a player in the local player's channel joins a team")
#define iTetPlayerSwitchedTeamGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has switched to team '%@'", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a player in the local player's channel changes from one team to another")
#define iTetPlayerLeftTeamGrowlNotificationMessageFormat		NSLocalizedStringFromTable(@"%@ has left team '%@'", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when a player in the local player's channel leaves his or her team")

- (void)playerEventNotification:(NSNotification*)notification
{
	// Determine the type of event, and post an appropriate Growl notification
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
	else if ([eventType isEqualToString:iTetPlayerKickedEventNotificationName])
	{
		// Player kicked
		// Determine if the local player is being kicked
		if ([[notification userInfo] boolForKey:iTetNotificationIsLocalPlayerKey])
		{
			[self postGrowlNotificationWithTitle:iTetLocalPlayerKickedGrowlNotificationTitle
									 description:iTetLocalPlayerKickedGrowlNotificationMessage
								notificationName:iTetPlayerKickedGrowlNotificationName];
		}
		else
		{
			[self postGrowlNotificationWithTitle:iTetPlayerKickedGrowlNotificationTitle
									 description:[NSString stringWithFormat:iTetPlayerKickedGrowlNotificationMessageFormat, nickname]
								notificationName:iTetPlayerKickedGrowlNotificationName];
		}
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

#define iTetGameEndedGrowlNotificationTitle				NSLocalizedStringFromTable(@"Game Ended", @"GrowlController", @"Title (first line) of Growl notification displayed when a game ends")
#define iTetGameEndedGrowlNotificationMessageFormat		NSLocalizedStringFromTable(@"%@ stopped the game", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when the operator ends the current game in progress")
#define iTetGamePlayerWonGrowlNotificationMessageFormat	NSLocalizedStringFromTable(@"%@ has won the game", @"GrowlController", @"Message contents (additional lines beyond the first) of the Growl notification displayed when the game ends with a winning player")

- (void)gameEventNotification:(NSNotification*)notification
{
	// Determine the type of event, and post an appropriate Growl notification
	NSString* eventType = [notification name];
	NSString* playerNickname = [[notification userInfo] objectForKey:iTetNotificationPlayerNicknameKey];
	if ([eventType isEqualToString:iTetGameEndedEventNotificationName])
	{
		// Game ended (stopped by operator, as opposed to a win by elimination of other players)
		[self postGrowlNotificationWithTitle:iTetGameEndedGrowlNotificationTitle
								 description:[NSString stringWithFormat:iTetGameEndedGrowlNotificationMessageFormat, playerNickname]
							notificationName:iTetGameEndedGrowlNotificationName];
	}
	else if ([eventType isEqualToString:iTetGamePlayerWonEventNotification])
	{
		// Game ended, with winning player
		[self postGrowlNotificationWithTitle:iTetGameEndedGrowlNotificationTitle
								 description:[NSString stringWithFormat:iTetGamePlayerWonGrowlNotificationMessageFormat, playerNickname]
							notificationName:iTetGameEndedGrowlNotificationName];
	}
}

- (void)postGrowlNotificationWithTitle:(NSString*)title
						   description:(NSString*)description
					  notificationName:(NSString*)name
{
	// If notifications are disabled, or enabled for background only and the app is in the foreground, skip sending the notification
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults boolForKey:iTetEnableGrowlNotificationsPrefKey] || ([NSApp isActive] && [defaults boolForKey:iTetGrowlBackgroundOnlyPrefKey]))
		return;
	
	// By default, iTetrinet's notifications use the default icon, have normal priority, are not sticky, and do not respond to clicks
	[GrowlApplicationBridge notifyWithTitle:title
								description:description
						   notificationName:name
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

@end
