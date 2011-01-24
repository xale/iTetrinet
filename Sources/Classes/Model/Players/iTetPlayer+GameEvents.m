//
//  iTetPlayer+GameEvents.m
//  iTetrinet
//
//  Created by Alex Heinz on 8/15/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayer+GameEvents.h"
#import "iTetTextAttributes.h"
#import "NSAttributedString+Convenience.h"

#define iTetServerSenderPlaceholderName			NSLocalizedStringFromTable(@"Server", @"Players", @"Placeholder string used in event description messages on the 'game actions' list when specials are used or lines are added by the server")
#define iTetTargetAllPlaceholderName			NSLocalizedStringFromTable(@"All", @"Players", @"Placeholder string used in event description messages on the 'game actions' list when a special is used on or lines are added to all players in the game")

@implementation iTetPlayer (GameEvents)

- (NSAttributedString*)senderEventDescriptionNickname
{
	if ([self isServerPlayer])
	{
		return [NSAttributedString attributedStringWithString:iTetServerSenderPlaceholderName
												   attributes:[iTetTextAttributes boldFontGameActionsTextAttributes]];
	}
	
	return [NSAttributedString attributedStringWithString:[self nickname]
											   attributes:[iTetTextAttributes boldFontGameActionsTextAttributes]];
}

- (NSAttributedString*)targetEventDescriptionNickname
{
	// (Server player object is used to represent "send-to-all" target)
	if ([self isServerPlayer])
	{
		return [NSAttributedString attributedStringWithString:iTetTargetAllPlaceholderName
												   attributes:[iTetTextAttributes boldFontGameActionsTextAttributes]];
	}
	
	return [NSAttributedString attributedStringWithString:[self nickname]
											   attributes:[iTetTextAttributes boldFontGameActionsTextAttributes]];
}

@end
