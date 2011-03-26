//
//  iTetWinlistMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/22/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetWinlistMessage.h"
#import "iTetWinlistEntry.h"
#import "NSArray+Subranges.h"

NSString* const iTetWinlistMessageTag =	@"winlist";

@implementation iTetWinlistMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	// Check that the message is not an empty list
	if ([tokens count] > 1)
	{
		// Iterate over the tokens in the list, starting with the second, and attempt to parse them into winlist entries
		// FIXME: does not handle team names with spaces
		NSMutableArray* entries = [NSMutableArray array];
		for (NSString* token in [tokens subarrayFromIndex:1])
		{
			// Ignore zero-length tokens
			if ([token length] == 0)
				continue;
			
			// Attempt to create a winlist entry from the token
			iTetWinlistEntry* entry = [iTetWinlistEntry entryWithWinlistMessageToken:token];
			
			// If the token cannot be parsed, log a warning, and try the next token
			if (entry == nil)
			{
				NSLog(@"WARNING: malformed winlist entry received: %@", token);
				continue;
			}
			
			// Otherwise, add the entry to the list
			[entries addObject:entry];
		}
		
		// Retain the list of entries
		winlistEntries = [entries copy];
	}
	
	return self;
}

+ (id)messageWithWinlistEntries:(NSArray*)entries
{
	return [[[self alloc] initWithWinlistEntries:entries] autorelease];
}

- (id)initWithWinlistEntries:(NSArray*)entries
{
	winlistEntries = [entries copy];
	
	return self;
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	// Begin with the message tag
	NSMutableString* messageContents = [NSMutableString stringWithString:iTetWinlistMessageTag];
	
	// Append a winlist-entry token for each entry in the list
	for (iTetWinlistEntry* entry in [self winlistEntries])
		[messageContents appendFormat:@" %@", [entry messageToken]];
	
	return messageContents;
}

#pragma mark -
#pragma mark Accessors

@synthesize winlistEntries;

@end
