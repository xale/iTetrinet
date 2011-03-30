//
//  iTetNewGameMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/29/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"

@interface iTetNewGameMessage : iTetMessage
{
	NSArray* rulesTokens;	/*!< An array of string tokens containing rules for the new game. */
}

+ (id)messageWithRulesTokens:(NSArray*)rules;
- (id)initWithRulesTokens:(NSArray*)rules;

- (NSString*)messageTag;

@property (readonly) NSArray* rulesTokens;

@end
