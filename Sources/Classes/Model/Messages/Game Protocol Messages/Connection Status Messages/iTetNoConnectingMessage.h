//
//  iTetNoConnectingMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetNoConnectingMessageTag;

@interface iTetNoConnectingMessage : iTetMessage
{
	NSString* reason;	/*!< The message, if any, provided by the server as a reason for denying the client connection. */
}

- (id)initWithReason:(NSString*)reasonMessage;

@property (readonly) NSString* reason;

@end
