//
//  iTetServerInfo.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/11/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetServerInfo.h"
#import "iTetNetworkController.h"
#import "iTetUserDefaults.h"

NSString* const iTetTetrinetProtocolName =	@"TetriNET";
NSString* const iTetTetrifastProtocolName =	@"Tetrifast";

NSString* const iTet113GameVersionName =	@"1.13";
NSString* const iTet114GameVersionName =	@"1.14";

@implementation iTetServerInfo

#define iTetExampleTetriNETServerName	NSLocalizedStringFromTable(@"Example TetriNET Server", @"ServerInfo", @"Name for example TetriNET server")
#define iTetExampleTetrifastServerName	NSLocalizedStringFromTable(@"Example Tetrifast Server", @"ServerInfo", @"Name for example Tetrifast server")
#define iTetExampleServerAddress		NSLocalizedStringFromTable(@"www.example.com", @"ServerInfo", @"Example server address (need not be a valid address)")
#define iTetExampleTeamName				NSLocalizedStringFromTable(@"MyTeam", @"ServerInfo", @"Example name for player's team (must not contain spaces)")

NSString* const iTetTetrinetUSTerinetServerName =		@"TetriNET.us (TetriNET)";
NSString* const iTetTetrinetUSTetrifastServerName =		@"TetriNET.us (Tetrifast)";
NSString* const iTetTetrinetUSServerAddress =			@"www.tetrinet.us";

+ (NSArray*)defaultServers
{
	return [NSArray arrayWithObjects:
			[iTetServerInfo serverInfoWithName:iTetTetrinetUSTerinetServerName
									   address:iTetTetrinetUSServerAddress
								playerNickname:NSUserName()
								playerTeamName:iTetExampleTeamName
									  protocol:tetrinetProtocol
								   gameVersion:version113],
			[iTetServerInfo serverInfoWithName:iTetTetrinetUSTetrifastServerName
									   address:iTetTetrinetUSServerAddress
								playerNickname:NSUserName()
								playerTeamName:iTetExampleTeamName
									  protocol:tetrifastProtocol
								   gameVersion:version113],
			[iTetServerInfo serverInfoWithName:iTetExampleTetriNETServerName
									   address:iTetExampleServerAddress
								playerNickname:NSUserName()
								playerTeamName:iTetExampleTeamName
									  protocol:tetrinetProtocol
								   gameVersion:version113],
			[iTetServerInfo serverInfoWithName:iTetExampleTetrifastServerName
									   address:iTetExampleServerAddress
								playerNickname:NSUserName()
								playerTeamName:iTetExampleTeamName
									  protocol:tetrifastProtocol
								   gameVersion:version113],
			nil];
}

+ (id)serverInfoWithName:(NSString*)name
				 address:(NSString*)addr
		  playerNickname:(NSString*)nick
		  playerTeamName:(NSString*)team
				protocol:(iTetProtocolType)p
			 gameVersion:(iTetGameVersion)version
{
	return [[[self alloc] initWithName:name
							   address:addr
						playerNickname:nick
						playerTeamName:team
							  protocol:p
						   gameVersion:version] autorelease];
}

- (id)initWithName:(NSString*)name
		   address:(NSString*)addr
	playerNickname:(NSString*)nick
	playerTeamName:(NSString*)team
		  protocol:(iTetProtocolType)p
	   gameVersion:(iTetGameVersion)version
{
	serverName = [name copy];
	serverAddress = [addr copy];
	playerNickname = [nick copy];
	playerTeamName = [team copy];
	protocol = p;
	gameVersion = version;
	
	return self;
}

#define iTetUnnamedServerPlaceholderName	NSLocalizedStringFromTable(@"Unnamed Server", @"ServerInfo", @"Placeholder name for unnamed servers")

- (id)init
{	
	return [self initWithName:iTetUnnamedServerPlaceholderName
					  address:iTetExampleServerAddress
			   playerNickname:NSUserName()
			   playerTeamName:iTetExampleTeamName
					 protocol:tetrinetProtocol
				  gameVersion:version113];
}

- (void)dealloc
{
	[serverName release];
	[serverAddress release];
	[playerNickname release];
	[playerTeamName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding Protocol

NSString* const iTetServerInfoNameCoderKey =			@"serverName";
NSString* const iTetServerInfoAddressCoderKey =			@"serverAddress";
NSString* const iTetServerInfoPlayerNicknameCoderKey =	@"playerNickname";
NSString* const iTetServerInfoPlayerTeamNameCoderKey =	@"playerTeamName";
NSString* const iTetServerInfoProtocolCoderKey =		@"protocol";
NSString* const iTetServerInfoGameVersionCoderKey =		@"gameVersion";

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:[self serverName]
				   forKey:iTetServerInfoNameCoderKey];
	[encoder encodeObject:[self serverAddress]
				   forKey:iTetServerInfoAddressCoderKey];
	[encoder encodeObject:[self playerNickname]
				   forKey:iTetServerInfoPlayerNicknameCoderKey];
	[encoder encodeObject:[self playerTeamName]
				   forKey:iTetServerInfoPlayerTeamNameCoderKey];
	[encoder encodeInt:[self protocol]
				forKey:iTetServerInfoProtocolCoderKey];
	[encoder encodeInt:[self gameVersion]
				forKey:iTetServerInfoGameVersionCoderKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	serverName = [[decoder decodeObjectForKey:iTetServerInfoNameCoderKey] retain];
	serverAddress = [[decoder decodeObjectForKey:iTetServerInfoAddressCoderKey] retain];
	playerNickname = [[decoder decodeObjectForKey:iTetServerInfoPlayerNicknameCoderKey] retain];
	playerTeamName = [[decoder decodeObjectForKey:iTetServerInfoPlayerTeamNameCoderKey] retain];
	protocol = [decoder decodeIntForKey:iTetServerInfoProtocolCoderKey];
	gameVersion = [decoder decodeIntForKey:iTetServerInfoGameVersionCoderKey];
	
	return self;
}

#pragma mark -
#pragma mark Key-Value Validation

NSString* const iTetInvalidNameErrorDomain =	@"iTetInvalidNickname";
typedef enum
{
	invalidNicknameErrorCode,
	invalidTeamNameErrorCode
} iTetInvalidNameErrorCode;

NSString* const iTetDefaultLocaleIdentifier =	@"en_US";
NSString* const iTetDefaultServerReservedName =	@"SERVER";
#define iTetLocalizedServerReservedName	NSLocalizedStringFromTable(@"SERVER", @"ServerInfo", @"The word 'SERVER' (as in the context of computer networks); used to prevent players from choosing this as their nickname")

#define iTetBlankNicknameErrorMessage	NSLocalizedStringFromTable(@"You must provide a nickname.", @"ServerInfo", @"Message displayed to users upon entering blank nickname")
#define iTetReservedNicknameErrorMessageFormat	NSLocalizedStringFromTable(@"The name '%@' is reserved; please choose another nickname.", @"ServerInfo", @"Message displayed to users if they enter a nickname that cannot be used.")

- (BOOL)validatePlayerNickname:(id*)newValue
						 error:(NSError**)error
{
	// Check that the nickname is not nil, or blank
	NSString* newNickname = (NSString*)*newValue;
	BOOL validName = YES;
	NSString* errorMessage = nil;
	if (newNickname == nil)
	{
		// No nickname specified
		validName = NO;
		errorMessage = iTetBlankNicknameErrorMessage;
		goto bail;
	}
	
	// Strip/sanitize whitespace
	newNickname = [iTetServerInfo serverSanitizedNickname:newNickname];
	
	// Check that the stripped nickname is not blank
	if ([newNickname length] <= 0)
	{
		// Blank nickname
		validName = NO;
		errorMessage = iTetBlankNicknameErrorMessage;
		goto bail;
	}
	
	// Check that the player is not trying to spoof the server name
	if ((([newNickname length] >= [iTetDefaultServerReservedName length]) &&
		 ([newNickname rangeOfString:iTetDefaultServerReservedName
							 options:(NSAnchoredSearch | NSCaseInsensitiveSearch)
							   range:NSMakeRange(0, [newNickname length])
							  locale:[[[NSLocale alloc] initWithLocaleIdentifier:iTetDefaultLocaleIdentifier] autorelease]].location != NSNotFound)) ||
		(([newNickname length] >= [iTetLocalizedServerReservedName length]) &&
		 ([newNickname rangeOfString:iTetLocalizedServerReservedName
							 options:(NSAnchoredSearch | NSCaseInsensitiveSearch)
							   range:NSMakeRange(0, [newNickname length])
							  locale:[NSLocale currentLocale]].location != NSNotFound)))
	{
		// Reserved nickname
		validName = NO;
		errorMessage = [NSString stringWithFormat:iTetReservedNicknameErrorMessageFormat, newNickname];
		goto bail;
	}
	
bail:;
	// If the nickname is invalid, and an error address has been provided, create an error object
	if (!validName && (error != NULL))
	{
		NSDictionary* infoDict = [NSDictionary dictionaryWithObject:errorMessage
															 forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:iTetInvalidNameErrorDomain
									 code:invalidNicknameErrorCode
								 userInfo:infoDict];
	}
	// Otherwise, change the final, accepted value to the sanitized nickname
	else if (validName)
	{
		*newValue = newNickname;
	}
	
	return validName;
}

- (BOOL)validatePlayerTeamName:(id*)newValue
						 error:(NSError**)error
{
	// Blank nicknames are valid
	NSString* newTeamName = (NSString*)*newValue;
	if (newTeamName == nil)
	{
		*newValue = [NSString string];
		return YES;
	}
	
	// Strip leading and trailing whitespace (may also result in a blank team name)
	*newValue = [iTetServerInfo serverSanitizedTeamName:newTeamName];
	
	// Team name is valid
	return YES;
}

+ (NSString*)serverSanitizedNickname:(NSString*)nickname
{
	// Strip whitespace from the ends of the name
	nickname = [nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Split the name on any internal whitespace characters
	NSArray* nameTokens = [nickname componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Re-join the name with underscores
	nickname = [nameTokens componentsJoinedByString:@"_"];
	
	return nickname;
}

+ (NSString*)serverSanitizedTeamName:(NSString*)teamName
{
	// Strip whitespace from the ends of the name
	return [teamName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark -
#pragma mark Comparators

- (BOOL)isEqual:(id)otherObject
{
	if ([otherObject isKindOfClass:[self class]])
	{
		iTetServerInfo* otherServer = (iTetServerInfo*)otherObject;
		return (([serverName localizedCompare:[otherServer serverName]] == NSOrderedSame) &&
				([serverAddress localizedCompare:[otherServer serverAddress]] == NSOrderedSame) &&
				([playerNickname localizedCompare:[otherServer playerNickname]] == NSOrderedSame) &&
				([playerTeamName localizedCompare:[otherServer playerTeamName]] == NSOrderedSame) &&
				(protocol == [otherServer protocol]) &&
				(gameVersion == [otherServer gameVersion]));
	}
	
	return NO;
}

#pragma mark -
#pragma mark Accessors

@synthesize serverName;
@synthesize serverAddress;
@synthesize playerNickname;
@synthesize playerTeamName;
@synthesize protocol;
@synthesize gameVersion;

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@: {%@, %@, %@, %@}", [super description], serverName, serverAddress, playerNickname, playerTeamName];
}

@end
