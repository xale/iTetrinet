//
//  iTetSpecialMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/5/10.
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
- (id)initWithSpecialType:(iTetSpecialType)special
			 senderNumber:(NSInteger)senderNum
			 targetNumber:(NSInteger)targetNum;

@property (readonly) iTetSpecialType specialType;
@property (readonly) NSInteger senderNumber;
@property (readonly) NSInteger targetNumber;

@end
