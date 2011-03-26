//
//  iTetWinlistMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/22/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetWinlistMessageTag;

@interface iTetWinlistMessage : iTetMessage
{
	NSArray* winlistEntries;	/*!< The list of winlist entries. */
}

+ (id)messageWithWinlistEntries:(NSArray*)entries;
- (id)initWithWinlistEntries:(NSArray*)entries;

@property (readonly) NSArray* winlistEntries;

@end
