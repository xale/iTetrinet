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

#pragma mark userInfo Dictionary Keys
NSString* const iTetNotificationPlayerNicknameKey =	@"iTetPlayerName";
NSString* const iTetNotificationIsLocalPlayerKey =	@"iTetIsLocalPlayer";
NSString* const iTetNotificationOldTeamNameKey =	@"iTetOldTeamName";
NSString* const iTetNotificationNewTeamNameKey =	@"iTetNewTeamName";
