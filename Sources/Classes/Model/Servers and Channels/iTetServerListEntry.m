//
//  iTetServerListEntry.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/4/11.
//  Copyright 2011 Indie Pennant Software. All rights reserved.
//

#import "iTetServerListEntry.h"

NSString* const iTetTetrinetProtocolName =	@"TetriNET";
NSString* const iTetTetrifastProtocolName =	@"Tetrifast";

NSString* const iTet113GameVersionName =	@"1.13";
NSString* const iTet114GameVersionName =	@"1.14";

NSString* const iTetServerListEntryXMLElementName =	@"server";
NSString* const iTetServerListEntryAddressXMLAttributeName =		@"name";
NSString* const iTetServerListEntryVersionXMLAttributeName =		@"verison";
NSString* const iTetServerListEntrySpectatorsXMLAttributeName =		@"spec";
NSString* const iTetServerListEntryCountryCodeXMLAttributeName =	@"country";
NSString* const iTetServerListEntryCountryNameXMLAttributeName =	@"countryName";
NSString* const iTetServerListEntryPingXMLAttributeName =			@"ping";
NSString* const iTetServerListEntryPlayersXMLAttributeName =		@"players";
NSString* const iTetServerListEntryActivePlayersXMLAttributeName =	@"activePlayers";
NSString* const iTetServerListEntryChannelsXMLAttributeName =		@"channels";
NSString* const iTetServerListEntryActiveChannelsXMLAttributeName =	@"activeChannels";

NSString* const iTetServerListEntryUnknownServerVersionPlaceholder =	@"Version unknown";
NSString* const iTetServerListEntryUnknownLocationPlaceholder =			@"Location unknown";
#define iTetServerListEntryMaximumDisplayedPing	999

@implementation iTetServerListEntry

+ (NSArray*)defaultFavoriteServers
{
	return [NSArray arrayWithObjects:
			[iTetServerListEntry serverListEntryWithServerAddress:@"tetrinet.us"],
			[iTetServerListEntry serverListEntryWithServerAddress:@"tetrinet.no"],
			nil];
}

+ (id)serverListEntryWithServerAddress:(NSString*)serverAddress
{
	return [[[self alloc] initWithServerAddress:serverAddress] autorelease];
}

- (id)initWithServerAddress:(NSString*)serverAddress
{
	address = [serverAddress copy];
	version = iTetServerListEntryUnknownServerVersionPlaceholder;
	allowsSpectators = NO;
	countryCode = nil;
	countryName = iTetServerListEntryUnknownLocationPlaceholder;
	ping = iTetServerListEntryMaximumDisplayedPing;
	numPlayers = NSNotFound;
	numActivePlayers = NSNotFound;
	numChannels = NSNotFound;
	numActiveChannels = NSNotFound;
	
	return self;
}

+ (id)serverListEntryWithServerListEntry:(iTetServerListEntry*)entry
{
	return [[[self alloc] initWithServerListEntry:entry] autorelease];
}

- (id)initWithServerListEntry:(iTetServerListEntry*)entry
{
	address = [[entry address] copy];
	version = [[entry version] copy];
	allowsSpectators = [entry allowsSpectators];
	countryCode = [[entry countryCode] copy];
	countryName = [[entry countryName] copy];
	ping = [entry ping];
	numPlayers = [entry	numPlayers];
	numActivePlayers = [entry numActivePlayers];
	numChannels = [entry numChannels];
	numActiveChannels = [entry numActiveChannels];
	
	return self;
}

+ (id)serverListEntryWithXMLServerDescription:(NSXMLElement*)XMLDescription
{
	return [[[self alloc] initWithXMLServerDescription:XMLDescription] autorelease];
}

- (id)initWithXMLServerDescription:(NSXMLElement*)XMLDescription
{
	// Check that the XML describing the server list entry is of the correct type
	NSString* elementType = [XMLDescription name];
	if (![elementType isEqualToString:iTetServerListEntryXMLElementName])
	{
		NSLog(@"Warning: attempting to load server description from XML element of invalid type: %@", elementType);
		[self release];
		return nil;
	}
	
	// Read the server's information from the attributes of the XML description
	// Server name
	NSXMLNode* attribute = [XMLDescription attributeForName:iTetServerListEntryAddressXMLAttributeName];
	if ((attribute == nil) || ([[attribute stringValue] length] == 0))
	{
		NSLog(@"Warning: no address provided for server with XML description: %@", XMLDescription);
		[self release];
		return nil;
	}
	address = [[attribute stringValue] copy];
	
	// Server version
	attribute = [XMLDescription attributeForName:iTetServerListEntryVersionXMLAttributeName];
	if ((attribute == nil) || ([[attribute stringValue] length] == 0))
		version = iTetServerListEntryUnknownServerVersionPlaceholder;
	else
		version = [[attribute stringValue] copy];
	
	// Spectators allowed
	attribute = [XMLDescription attributeForName:iTetServerListEntrySpectatorsXMLAttributeName];
	allowsSpectators = [[attribute objectValue] boolValue];	// Gives us "NO" if unspecified
	
	// Country code
	attribute = [XMLDescription attributeForName:iTetServerListEntryCountryNameXMLAttributeName];
	countryCode = [[attribute stringValue] copy];	// Gives us "nil" if no code is provided
	
	// Country name
	attribute = [XMLDescription attributeForName:iTetServerListEntryCountryNameXMLAttributeName];
	if ((attribute == nil) || ([[attribute stringValue] length] == 0))
		countryName = iTetServerListEntryUnknownLocationPlaceholder;
	else
		countryName = [[attribute stringValue] copy];
	
	// Ping
	attribute = [XMLDescription attributeForName:iTetServerListEntryPingXMLAttributeName];
	if ((attribute == nil) || ([[attribute objectValue] integerValue] >= iTetServerListEntryMaximumDisplayedPing))
		ping = iTetServerListEntryMaximumDisplayedPing;
	else
		ping = [[attribute objectValue] integerValue];
	
	// Number of players
	attribute = [XMLDescription attributeForName:iTetServerListEntryPlayersXMLAttributeName];
	if (attribute == nil)
		numPlayers = NSNotFound;
	else
		numPlayers = [[attribute objectValue] integerValue];
	
	// Number of active players
	attribute = [XMLDescription attributeForName:iTetServerListEntryActivePlayersXMLAttributeName];
	if (attribute == nil)
		numActivePlayers = NSNotFound;
	else
		numActivePlayers = [[attribute objectValue] integerValue];
	
	// Number of channels
	attribute = [XMLDescription attributeForName:iTetServerListEntryChannelsXMLAttributeName];
	if (attribute == nil)
		numChannels = NSNotFound;
	else
		numChannels = [[attribute objectValue] integerValue];
	
	// Number of channels with active players
	attribute = [XMLDescription attributeForName:iTetServerListEntryActiveChannelsXMLAttributeName];
	if (attribute == nil)
		numActiveChannels = NSNotFound;
	else
		numActiveChannels = [[attribute objectValue] integerValue];
	
	return self;
}

- (void)dealloc
{
	[address release];
	[version release];
	[countryCode release];
	[countryName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
	return [[[self class] allocWithZone:zone] initWithServerListEntry:self];
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder*)encoder
{
	// Store only the server address; remaining data will be pulled from the master server, if possible
	[encoder encodeObject:[self address]
				   forKey:@"address"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	return [self initWithServerAddress:[decoder decodeObjectForKey:@"address"]];
}

#pragma mark -
#pragma mark Comparison

- (BOOL)isEqual:(id)otherObj
{
	if ([otherObj isKindOfClass:[self class]])
	{
		iTetServerListEntry* otherEntry = (iTetServerListEntry*)otherObj;
		
		return [[self address] isEqualToString:[otherEntry address]];
	}
	
	return NO;
}

- (NSUInteger)hash
{
	return [[self address] hash];
}

#pragma mark -
#pragma mark Accessors

NSString* const iTetServerListEntryInvalidServerUpdateExceptionFormat =	@"attempting to update server list entry '%@' with data from server '%@'";

- (void)updateFromServerListEntry:(iTetServerListEntry*)updateEntry
{
	// Check that we're updating the correct server entry
	if (![[self address] isEqualToString:[updateEntry address]])
	{
		NSString* excDesc = [NSString stringWithFormat:iTetServerListEntryInvalidServerUpdateExceptionFormat, [self address], [updateEntry address]];
		NSException* invalidUpdateException = [NSException exceptionWithName:NSInternalInconsistencyException
																	  reason:excDesc
																	userInfo:nil];
		@throw invalidUpdateException;
	}
	
	// Update the entry with the received data
	[self setVersion:[updateEntry version]];
	[self setAllowsSpectators:[updateEntry allowsSpectators]];
	[self setCountryCode:[updateEntry countryCode]];
	[self setCountryName:[updateEntry countryName]];
	[self setPing:[updateEntry ping]];
	[self setNumPlayers:[updateEntry numPlayers]];
	[self setNumActivePlayers:[updateEntry numActivePlayers]];
	[self setNumChannels:[updateEntry numChannels]];
	[self setNumActiveChannels:[updateEntry numActiveChannels]];
}

@synthesize address;
@synthesize version;
@synthesize allowsSpectators;
@synthesize countryCode;
@synthesize countryName;
@synthesize ping;
@synthesize numPlayers;
@synthesize numActivePlayers;

- (BOOL)hasActivePlayers
{
	return ((numActivePlayers != NSNotFound) && ([self numActivePlayers] > 0));
}
+ (NSSet*)keyPathsForValuesAffectingHasActivePlayers
{
	return [NSSet setWithObject:@"numActivePlayers"];
}

@synthesize numChannels;
@synthesize numActiveChannels;

@end
