//
//  iTetLoginMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@interface iTetLoginMessage : iTetMessage
{
	NSString* playerNickname;	/*!< The nickname of the player logging in. May not contain whitespace. */
	NSString* protocolVersion;	/*!< The TetriNET protocol version ("1.13" or "1.14") the player's client is using. */
	NSString* serverAddress;	/*!< The address (in four-octet IPv4 form) of the server to which this message is being sent. */
}

+ (id)messageWithPlayerNickname:(NSString*)nickname
				protocolVersion:(NSString*)version
			  destinationServer:(NSString*)destinationAddress;
- (id)initWithPlayerNickname:(NSString*)nickname
			 protocolVersion:(NSString*)version
		   destinationServer:(NSString*)destinationAddress;

/*!
 @warning Abstract method; subclasses must override.
 Returns the message tag used by this login message, which varies from one protocol to another.
 */
- (NSString*)messageTag;

@property (readonly) NSString* playerNickname;
@property (readonly) NSString* protocolVersion;
@property (readonly) NSString* serverAddress;

@end
