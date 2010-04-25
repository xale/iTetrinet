//
//  iTetServerInfo.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/11/09.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	tetrinetProtocol = 1,
	tetrifastProtocol = 2
} iTetProtocolType;

@interface iTetServerInfo : NSObject <NSCoding>
{
	NSString* serverName;
	NSString* serverAddress;
	NSString* playerNickname;
	NSString* playerTeamName;
	iTetProtocolType protocol;
}

+ (NSArray*)defaultServers;
+ (id)serverInfoWithName:(NSString*)name
				 address:(NSString*)addr
		  playerNickname:(NSString*)nick
		  playerTeamName:(NSString*)team
				protocol:(iTetProtocolType)p;
- (id)initWithName:(NSString*)name
		   address:(NSString*)addr
	playerNickname:(NSString*)nick
	playerTeamName:(NSString*)team
		  protocol:(iTetProtocolType)p;

@property (readwrite, copy) NSString* serverName;
@property (readwrite, copy) NSString* serverAddress;
@property (readwrite, copy) NSString* playerNickname;
@property (readwrite, copy) NSString* playerTeamName;
@property (readwrite, assign) iTetProtocolType protocol;

@end
