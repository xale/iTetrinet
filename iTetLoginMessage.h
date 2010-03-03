//
//  iTetLoginMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetMessage.h"
#import "iTetServerInfo.h"

@interface iTetLoginMessage : iTetMessage <iTetOutgoingMessage>
{
	iTetProtocolType protocol;
	NSString* nickname;
	NSString* address;
}

+ (id)loginMessageWithProtocol:(iTetProtocolType)gameProtocol
					  nickname:(NSString*)playerNickname
					   address:(NSString*)ipv4ServerAddress;
- (id)initWithProtocol:(iTetProtocolType)gameProtocol
			  nickname:(NSString*)playerNickname
			   address:(NSString*)ipv4ServerAddress;

@property (readonly) iTetProtocolType protocol;
@property (readonly) NSString* nickname;
@property (readonly) NSString* address;

@end
