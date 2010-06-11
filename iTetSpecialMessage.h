//
//  iTetSpecialMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"
#import "iTetSpecials.h"

@class iTetPlayer;

@interface iTetSpecialMessage : iTetMessage <iTetIncomingMessage, iTetOutgoingMessage>
{
	iTetSpecialType specialType;
	NSInteger senderNumber;
	NSInteger targetNumber;
}

+ (id)messageWithSpecialType:(iTetSpecialType)special
					  sender:(iTetPlayer*)sender
					  target:(iTetPlayer*)target;
+ (id)messageWithClassicStyleLines:(NSInteger)lines
							sender:(iTetPlayer*)sender;
- (id)initWithSpecialType:(iTetSpecialType)special
			 senderNumber:(NSInteger)senderNum
			 targetNumber:(NSInteger)targetNum;

@property (readonly) iTetSpecialType specialType;
@property (readonly) NSInteger senderNumber;
@property (readonly) NSInteger targetNumber;

@end
