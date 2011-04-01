//
//  iTetTetrifastGameConnection.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetTetrifastGameConnection.h"

#import "iTetTetrinetNewGameMessage.h"
#import "iTetTetrifastNewGameMessage.h"
#import "iTetTetrinetPlayerNumberMessage.h"
#import "iTetTetrifastPlayerNumberMessage.h"

static NSDictionary* tetrifastMessageDictionary =	nil;

@interface iTetTetrifastGameConnection(Private)

- (NSDictionary*)tetrifastMessageDictionary;

@end

@implementation iTetTetrifastGameConnection

- (NSDictionary*)messageTypesByTag
{
	@synchronized(self)
	{
		if (tetrifastMessageDictionary == nil)
		{
			tetrifastMessageDictionary = [[self tetrifastMessageDictionary] copy];
		}
	}
	
	return tetrifastMessageDictionary;
}

- (NSDictionary*)tetrifastMessageDictionary
{
	// Use the default TetriNET protocol message dictionary as a basis
	NSMutableDictionary* messages = [NSMutableDictionary dictionaryWithDictionary:[super messageTypesByTag]];
	
	// Remove the TetriNET-protocol-specific messages
	[messages removeObjectForKey:iTetTetrinetNewGameMessageTag];
	[messages removeObjectForKey:iTetTetrinetPlayerNumberMessageTag];
	
	// Replace with the Tetrifast-protocol equivalents
	[messages setObject:[iTetTetrifastNewGameMessage class]
				 forKey:iTetTetrifastNewGameMessageTag];
	[messages setObject:[iTetTetrifastPlayerNumberMessage class]
				 forKey:iTetTetrifastPlayerNumberMessageTag];
	
	return messages;
}

@end
