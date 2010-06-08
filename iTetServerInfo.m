//
//  iTetServerInfo.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/11/09.
//

#import "iTetServerInfo.h"
#import "iTetNetworkController.h"
#import "iTetUserDefaults.h"

@interface iTetServerInfo (Private)

- (NSString*)sanitizedName:(NSString*)inputString;

@end

@implementation iTetServerInfo

#define iTetExampleTetriNETServerName	NSLocalizedStringFromTable(@"Example TetriNET Server", @"ServerInfo", @"Name for example TetriNET server")
#define iTetExampleTetrifastServerName	NSLocalizedStringFromTable(@"Example Tetrifast Server", @"ServerInfo", @"Name for example Tetrifast server")
#define iTetExampleServerAddress		NSLocalizedStringFromTable(@"www.example.com", @"ServerInfo", @"Example server address (need not be a valid address)")
#define iTetExampleTeamName				NSLocalizedStringFromTable(@"MyTeam", @"ServerInfo", @"Example name for player's team (must not contain spaces)")

+ (NSArray*)defaultServers
{
	return [NSArray arrayWithObjects:
			[iTetServerInfo serverInfoWithName:iTetExampleTetriNETServerName
									   address:iTetExampleServerAddress
								playerNickname:NSUserName()
								playerTeamName:iTetExampleTeamName
									  protocol:tetrinetProtocol],
			[iTetServerInfo serverInfoWithName:iTetExampleTetrifastServerName
									   address:iTetExampleServerAddress
								playerNickname:NSUserName()
								playerTeamName:iTetExampleTeamName
									  protocol:tetrifastProtocol],
			nil];
}

+ (id)serverInfoWithName:(NSString*)name
				 address:(NSString*)addr
		  playerNickname:(NSString*)nick
		  playerTeamName:(NSString*)team
				protocol:(iTetProtocolType)p
{
	return [[[self alloc] initWithName:name
							   address:addr
						playerNickname:nick
						playerTeamName:team
							  protocol:p] autorelease];
}

- (id)initWithName:(NSString*)name
		   address:(NSString*)addr
	playerNickname:(NSString*)nick
	playerTeamName:(NSString*)team
		  protocol:(iTetProtocolType)p
{
	serverName = [name copy];
	serverAddress = [addr copy];
	playerNickname = [nick copy];
	playerTeamName = [team copy];
	protocol = p;
	
	return self;
}

#define iTetUnnamedServerPlaceholderName	NSLocalizedStringFromTable(@"Unnamed Server", @"ServerInfo", @"Placeholder name for unnamed servers")

- (id)init
{	
	return [self initWithName:iTetUnnamedServerPlaceholderName
					  address:iTetExampleServerAddress
			   playerNickname:NSUserName()
			   playerTeamName:iTetExampleTeamName
					 protocol:tetrinetProtocol];
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

NSString* const iTetServerInfoNameArchiverKey =				@"serverName";
NSString* const iTetServerInfoAddressArchiverKey =			@"serverAddress";
NSString* const iTetServerInfoPlayerNicknameArchiverKey =	@"playerNickname";
NSString* const iTetServerInfoPlayerTeamNameArchiverKey =	@"playerTeamName";
NSString* const iTetServerInfoProtocolArchiverKey =			@"protocol";

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:[self serverName]
				   forKey:iTetServerInfoNameArchiverKey];
	[encoder encodeObject:[self serverAddress]
				   forKey:iTetServerInfoAddressArchiverKey];
	[encoder encodeObject:[self playerNickname]
				   forKey:iTetServerInfoPlayerNicknameArchiverKey];
	[encoder encodeObject:[self playerTeamName]
				   forKey:iTetServerInfoPlayerTeamNameArchiverKey];
	[encoder encodeInt:[self protocol]
				forKey:iTetServerInfoProtocolArchiverKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	serverName = [[decoder decodeObjectForKey:iTetServerInfoNameArchiverKey] retain];
	serverAddress = [[decoder decodeObjectForKey:iTetServerInfoAddressArchiverKey] retain];
	playerNickname = [[decoder decodeObjectForKey:iTetServerInfoPlayerNicknameArchiverKey] retain];
	playerTeamName = [[decoder decodeObjectForKey:iTetServerInfoPlayerTeamNameArchiverKey] retain];
	protocol = [decoder decodeIntForKey:iTetServerInfoProtocolArchiverKey];
	
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
	// Check that the new value is not nil, or blank
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
	newNickname = [self sanitizedName:newNickname];
	
	// Check that the nickname is not blank
	if ([newNickname length] <= 0)
	{
		// Blank nickname
		validName = NO;
		errorMessage = iTetBlankNicknameErrorMessage;
		goto bail;
	}
	
	// Check that the player is not trying to spoof the server
	if (([newNickname rangeOfString:iTetDefaultServerReservedName
							options:(NSAnchoredSearch | NSCaseInsensitiveSearch)
							  range:NSMakeRange(0, [iTetDefaultServerReservedName length])
							 locale:[[[NSLocale alloc] initWithLocaleIdentifier:iTetDefaultLocaleIdentifier] autorelease]].location != NSNotFound) ||
		([newNickname rangeOfString:iTetLocalizedServerReservedName
							options:(NSAnchoredSearch | NSCaseInsensitiveSearch)
							  range:NSMakeRange(0, [iTetLocalizedServerReservedName length])
							 locale:[NSLocale currentLocale]].location != NSNotFound))
	{
		// Reserved nickname
		validName = NO;
		errorMessage = [NSString stringWithFormat:iTetReservedNicknameErrorMessageFormat, newNickname];
		goto bail;
	}
	
bail:
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
	
	// Sanitize any whitespace characters
	*newValue = [self sanitizedName:newTeamName];
	
	// Team name is valid
	return YES;
}

- (NSString*)sanitizedName:(NSString*)inputString
{
	// Strip whitespace from the ends of the name
	inputString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Split the name on any internal whitespace characters
	NSArray* nameTokens = [inputString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Re-join the name with underscores
	inputString = [nameTokens componentsJoinedByString:@"_"];
	
	return inputString;
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
				(protocol == [otherServer protocol]));
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

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@: {%@, %@, %@, %@}", [super description], serverName, serverAddress, playerNickname, playerTeamName];
}

@end
