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
	NSString* address;
	NSString* nickname;
	NSString* playerTeam;
	iTetProtocolType protocol;
}

+ (NSArray*)defaultServers;
+ (id)serverInfoWithName:(NSString*)name
		     address:(NSString*)addr
		    nickname:(NSString*)nick
			  team:(NSString*)team
		    protocol:(iTetProtocolType)p;
- (id)initWithName:(NSString*)name
	     address:(NSString*)addr
	    nickname:(NSString*)nick
		  team:(NSString*)team
	    protocol:(iTetProtocolType)p;

@property (readwrite, copy) NSString* serverName;
@property (readwrite, copy) NSString* address;
@property (readwrite, copy) NSString* nickname;
@property (readwrite, copy) NSString* playerTeam;
@property (readwrite, assign) iTetProtocolType protocol;

@end
