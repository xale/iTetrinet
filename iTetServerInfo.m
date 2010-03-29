//
//  iTetServerInfo.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/11/09.
//

#import "iTetServerInfo.h"

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
	playerTeam = [team copy];
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
	[playerTeam release];
	
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
	[encoder encodeObject:[self playerTeam]
				   forKey:iTetServerInfoPlayerTeamKey];
	[encoder encodeInt:[self protocol]
				forKey:iTetServerInfoProtocolKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	serverName = [[decoder decodeObjectForKey:iTetServerInfoServerNameKey] retain];
	address = [[decoder decodeObjectForKey:iTetServerInfoAddressKey] retain];
	nickname = [[decoder decodeObjectForKey:iTetServerInfoNicknameKey] retain];
	playerTeam = [[decoder decodeObjectForKey:iTetServerInfoPlayerTeamKey] retain];
	protocol = [decoder decodeIntForKey:iTetServerInfoProtocolKey];
	
	return self;
}

#pragma mark -
#pragma mark Key-Value Validation

NSString* const iTetInvalidNicknameErrorDomain =	@"iTetInvalidNickname";
#define iTetInvalidNicknameErrorCode				(1)

- (BOOL)validateNickname:(id*)newValue
				   error:(NSError**)error
{
	// Check that the new value is not nil, or blank
	NSString* newNickname = (NSString*)*newValue;
	if ((newNickname == nil) || ([newNickname length] == 0))
	{
		// If an error address has been provided, create an error object
		if (error != NULL)
		{
			NSDictionary* infoDict = [NSDictionary dictionaryWithObject:@"You must provide a nickname."
																 forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:iTetInvalidNicknameErrorDomain
										 code:iTetInvalidNicknameErrorCode
									 userInfo:infoDict];
		}
		
		// Nickname is invalid
		return NO;
	}
	
	// Strip whitespace from the ends of the nickname
	newNickname = [newNickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Split the nickname on any internal whitespace characters
	NSArray* nicknameTokens = [newNickname componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Re-join the nickame with underscores
	*newValue = [nicknameTokens componentsJoinedByString:@"_"];
	
	// Nickname is valid
	return YES;
}

#pragma mark -
#pragma mark Accessors

@synthesize serverName;
@synthesize address;
@synthesize nickname;
@synthesize playerTeam;
@synthesize protocol;

- (NSString*)description
{
	return [NSString stringWithFormat:
			@"iTetServerInfo; serverName: %@; address: %@; nickname: %@; playerTeam: %@",
			serverName, address, nickname, playerTeam];
}

@end
