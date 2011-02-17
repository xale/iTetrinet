//
//  iTetServerListEntry.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/4/11.
//  Copyright 2011 Indie Pennant Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	tetrinetProtocol = 1,
	tetrifastProtocol = 2
} iTetProtocolType;

extern NSString* const iTetTetrinetProtocolName;
extern NSString* const iTetTetrifastProtocolName;

typedef enum
{
	version113 = 1,
	version114 = 2
} iTetGameVersion;

extern NSString* const iTet113GameVersionName;
extern NSString* const iTet114GameVersionName;

@interface iTetServerListEntry : NSObject <NSCopying, NSCoding>
{
	NSString* address;
	NSString* version;
	BOOL allowsSpectators;
	NSString* countryCode;
	NSString* countryName;
	NSInteger ping;
	NSInteger numPlayers;
	NSInteger numActivePlayers;
	NSInteger numChannels;
	NSInteger numActiveChannels;
}

+ (id)serverListEntryWithServerAddress:(NSString*)serverAddress;
- (id)initWithServerAddress:(NSString*)serverAddress;

+ (id)serverListEntryWithServerListEntry:(iTetServerListEntry*)entry;
- (id)initWithServerListEntry:(iTetServerListEntry*)entry;

+ (id)serverListEntryWithXMLServerDescription:(NSXMLElement*)XMLDescription;
- (id)initWithXMLServerDescription:(NSXMLElement*)XMLDescription;

@property (readonly) NSString* address;
@property (readwrite, copy) NSString* version;
@property (readwrite, assign) BOOL allowsSpectators;
@property (readwrite, copy) NSString* countryCode;
@property (readwrite, copy) NSString* countryName;
@property (readwrite, assign) NSInteger ping;
@property (readwrite, assign) NSInteger numPlayers;
@property (readwrite, assign) NSInteger numActivePlayers;
@property (readonly) BOOL hasActivePlayers;
@property (readwrite, assign) NSInteger numChannels;
@property (readwrite, assign) NSInteger numActiveChannels;

@end
