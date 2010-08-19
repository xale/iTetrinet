//
//  iTetNotifications.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/18/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

#pragma mark Notification Names
extern NSString* const iTetPlayerJoinedEventNotificationName;
extern NSString* const iTetPlayerLeftEventNotificationName;
extern NSString* const iTetPlayerKickedEventNotificationName;
extern NSString* const iTetPlayerTeamChangeEventNotificationName;

#pragma mark userInfo Dictionary Keys
extern NSString* const iTetNotificationPlayerNicknameKey;
extern NSString* const iTetNotificationIsLocalPlayerKey;
extern NSString* const iTetNotificationOldTeamNameKey;
extern NSString* const iTetNotificationNewTeamNameKey;
