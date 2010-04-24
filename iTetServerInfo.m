//
//  iTetServerInfo.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/11/09.
//

#import "iTetServerInfo.h"
#import "iTetNetworkController.h"

@interface iTetServerInfo (Private)

- (NSString*)sanitizedName:(NSString*)inputString;

@end


@implementation iTetServerInfo

+ (NSArray*)defaultServers
{
	return [NSArray arrayWithObjects:
			[iTetServerInfo serverInfoWithName:@"Example TetriNET Server"
									   address:@"www.example.com"
									  nickname:NSUserName()
										  team:@""
									  protocol:tetrinetProtocol],
			[iTetServerInfo serverInfoWithName:@"Example Tetrifast Server"
									   address:@"www.example.com"
									  nickname:NSUserName()
										  team:@""
									  protocol:tetrifastProtocol],
			nil];
}

+ (id)serverInfoWithName:(NSString*)name
				 address:(NSString*)addr
				nickname:(NSString*)nick
					team:(NSString*)team
				protocol:(iTetProtocolType)p
{
	return [[[self alloc] initWithName:name
							   address:addr
							  nickname:nick
								  team:team
							  protocol:p] autorelease];
}

- (id)initWithName:(NSString*)name
		   address:(NSString*)addr
		  nickname:(NSString*)nick
			  team:(NSString*)team
		  protocol:(iTetProtocolType)p
{
	serverName = [name copy];
	address = [addr copy];
	nickname = [nick copy];
	teamName = [team copy];
	protocol = p;
	
	return self;
}

- (id)init
{	
	return [self initWithName:@"Unnamed Server"
					  address:@"www.example.com"
					 nickname:NSUserName()
						 team:@""
					 protocol:tetrinetProtocol];
}

- (void)dealloc
{
	[serverName release];
	[address release];
	[nickname release];
	[teamName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding Protocol

NSString* const iTetServerInfoServerNameKey =	@"serverName";
NSString* const iTetServerInfoAddressKey =		@"address";
NSString* const iTetServerInfoNicknameKey =		@"nickname";
NSString* const iTetServerInfoPlayerTeamKey =	@"playerTeam";
NSString* const iTetServerInfoProtocolKey =		@"protocol";

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:[self serverName]
				   forKey:iTetServerInfoServerNameKey];
	[encoder encodeObject:[self address]
				   forKey:iTetServerInfoAddressKey];
	[encoder encodeObject:[self nickname]
				   forKey:iTetServerInfoNicknameKey];
	[encoder encodeObject:[self teamName]
				   forKey:iTetServerInfoPlayerTeamKey];
	[encoder encodeInt:[self protocol]
				forKey:iTetServerInfoProtocolKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	serverName = [[decoder decodeObjectForKey:iTetServerInfoServerNameKey] retain];
	address = [[decoder decodeObjectForKey:iTetServerInfoAddressKey] retain];
	nickname = [[decoder decodeObjectForKey:iTetServerInfoNicknameKey] retain];
	teamName = [[decoder decodeObjectForKey:iTetServerInfoPlayerTeamKey] retain];
	protocol = [decoder decodeIntForKey:iTetServerInfoProtocolKey];
	
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

NSString* const iTetServerReservedName =	@"SERVER";

NSString* const iTetBlankNicknameErrorMessage =				@"You must provide a nickname.";
NSString* const iTetReservedNicknameErrorMessageFormat =	@"The name '%@' is reserved; please choose another nickname.";

- (BOOL)validateNickname:(id*)newValue
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
		errorMessage = [NSString stringWithString:iTetBlankNicknameErrorMessage];
		goto bail;
	}
	
	// Strip/sanitize whitespace
	newNickname = [self sanitizedName:newNickname];
	
	// Check that the nickname is not blank
	if ([newNickname length] <= 0)
	{
		// Blank nickname
		validName = NO;
		errorMessage = [NSString stringWithString:iTetBlankNicknameErrorMessage];
		goto bail;
	}
	
	// Check that the player is not trying to spoof the server
	if ([newNickname rangeOfString:iTetServerReservedName options:(NSAnchoredSearch | NSCaseInsensitiveSearch)].location != NSNotFound)
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

- (BOOL)validateTeamName:(id*)newValue
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
		return ([serverName isEqualToString:[otherServer serverName]] &&
				[address isEqualToString:[otherServer address]] &&
				[nickname isEqualToString:[otherServer nickname]] &&
				[teamName isEqualToString:[otherServer teamName]] &&
				(protocol == [otherServer protocol]));
	}
	
	return NO;
}

#pragma mark -
#pragma mark Accessors

@synthesize serverName;
@synthesize address;
@synthesize nickname;
@synthesize teamName;
@synthesize protocol;

- (NSString*)description
{
	return [NSString stringWithFormat:@"iTetServerInfo; serverName: %@; address: %@; nickname: %@; playerTeam: %@", serverName, address, nickname, teamName];
}

@end
