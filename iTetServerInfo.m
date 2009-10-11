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
	// FIXME: debug implementation
	return [NSArray arrayWithObjects:
		  [iTetServerInfo serverInfoWithName:@"Tetrinet Test"
						     address:@"www.example.com"
						    nickname:@"Xale"
							  team:@""
						    protocol:tetrinetProtocol],
		  [iTetServerInfo serverInfoWithName:@"nenoth"
						     address:@"nenoth.ietfng.org"
						    nickname:@"Xale_Testing"
							  team:@""
						    protocol:tetrifastProtocol],
		  [iTetServerInfo serverInfoWithName:@"Local Test"
						     address:@"5.147.159.117"
						    nickname:@"Xale"
							  team:@""
						    protocol:tetrifastProtocol],
		  [iTetServerInfo serverInfoWithName:@"Local Test (Alt. Nick)"
						     address:@"5.147.159.117"
						    nickname:@"Xale2"
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
NSString* const iTetServerInfoAddressKey =	@"address";
NSString* const iTetServerInfoNicknameKey =	@"nickname";
NSString* const iTetServerInfoPlayerTeamKey =	@"playerTeam";
NSString* const iTetServerInfoProtocolKey =	@"protocol";

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
#pragma mark Accessors (Synthesized)

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
