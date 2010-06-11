//
//  iTetLoginMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"
#import "iTetServerInfo.h"

@interface iTetLoginMessage : iTetMessage <iTetOutgoingMessage>
{
	iTetProtocolType protocol;
	NSString* nickname;
	NSString* address;
}

+ (id)messageWithProtocol:(iTetProtocolType)gameProtocol
				 nickname:(NSString*)playerNickname
				  address:(NSString*)ipv4ServerAddress;
- (id)initWithProtocol:(iTetProtocolType)gameProtocol
			  nickname:(NSString*)playerNickname
			   address:(NSString*)ipv4ServerAddress;

@property (readonly) iTetProtocolType protocol;
@property (readonly) NSString* nickname;
@property (readonly) NSString* address;

@end
