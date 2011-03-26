//
//  iTetClientInfoResponseMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetClientInfoResponseMessageTag;

@interface iTetClientInfoResponseMessage : iTetMessage
{
	NSString* clientName;	/*!< The name by which the client identifies itself. May not contain whitespace. */
	NSString* clientVersion;	/*!< The client version, as a string. May not contain whitespace. */
}

+ (id)messageWithClientName:(NSString*)name
					version:(NSString*)version;
- (id)initWithClientName:(NSString*)name
				 version:(NSString*)version;

@property (readonly) NSString* clientName;
@property (readonly) NSString* clientVersion;

@end
