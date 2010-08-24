//
//  iTetNotifications.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/18/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNotifications.h"

#pragma mark Notification Names
NSString* const iTetPlayerJoinedEventNotificationName =		@"com.indiepennant.iTetrinet.playerJoinedEventNotification";
NSString* const iTetPlayerLeftEventNotificationName =		@"com.indiepennant.iTetrinet.playerLeftEventNotification";
NSString* const iTetPlayerKickedEventNotificationName =		@"com.indiepennant.iTetrinet.playerKickedEventNotification";
NSString* const iTetPlayerTeamChangeEventNotificationName =	@"com.indiepennant.iTetrinet.playerTeamChangedEventNotification";
NSString* const iTetGameStartedEventNotificationName =		@"com.indiepennant.iTetrinet.gameStartedEventNotification";
NSString* const iTetGamePausedEventNotificationName =		@"com.indiepennant.iTetrinet.gamePausedEventNotification";
NSString* const iTetGameResumedEventNotificationName =		@"com.indiepennant.iTetrinet.gameResumedEventNotification";
NSString* const iTetGameEndedEventNotificationName =		@"com.indiepennant.iTetrinet.gameEndedEventNotification";
NSString* const iTetGamePlayerLostEventNotificationName =		@"com.indiepennant.iTetrinet.gamePlayerLostEventNotification";
NSString* const iTetGamePlayerWonEventNotificationName =		@"com.indiepennant.iTetrinet.gamePlayerWonEventNotification";

#pragma mark userInfo Dictionary Keys
NSString* const iTetNotificationPlayerKey =			@"iTetNotificationPlayer";
NSString* const iTetNotificationOldTeamNameKey =	@"iTetNotificationOldTeamName";
NSString* const iTetNotificationNewTeamNameKey =	@"iTetNotificationNewTeamName";
