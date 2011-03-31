//
//  iTetFieldUpdateMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

extern NSString* const iTetFieldUpdateMessageTag;

@interface iTetFieldUpdateMessage : iTetMessage
{
	NSInteger playerNumber;	/*!< The player-slot-number of the player whose field has changed. */
	NSString* fieldstring;	/*!< The string containing the field-update data. */
}

+ (id)messageWithPlayerNumber:(NSInteger)number
				  fieldstring:(NSString*)string;
- (id)initWithPlayerNumber:(NSInteger)number
			   fieldstring:(NSString*)string;

@property (readonly) NSInteger playerNumber;
@property (readonly) NSString* fieldstring;

@end
