//
//  iTetWinlistViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetWinlistViewController.h"
#import "iTetWinlistEntry.h"

@implementation iTetWinlistViewController

NSString* const	iTetPlayerWinlistEntryCharacter =	@"p";
NSString* const iTetTeamWinlistEntryCharacter =		@"t";

- (void)parseWinlist:(NSArray*)winlistTokens
{
	NSMutableArray* winlistEntries = [NSMutableArray array];
	
	// Iterate through the list of players and teams
	NSArray* entryComponents;
	for (NSString* entryToken in winlistTokens)
	{
		// Check that this token is of non-zero length
		if ([entryToken length] == 0)
			continue;
		
		// Divide the token at the semicolon delimiter
		entryComponents = [entryToken componentsSeparatedByString:@";"];
		if ([entryComponents count] < 2)
		{
			NSLog(@"WARNING: malformed winlist entry: %@", entryToken);
			continue;
		}
		
		// Determine if this entry represents a player or a team
		if ([entryToken rangeOfString:iTetPlayerWinlistEntryCharacter
							  options:(NSAnchoredSearch | NSCaseInsensitiveSearch)].location != NSNotFound)
		{
			[winlistEntries addObject:[iTetWinlistEntry playerEntryWithName:[[entryComponents objectAtIndex:0] substringFromIndex:1]
																	  score:[[entryComponents objectAtIndex:1] integerValue]]];
		}
		else if ([entryToken rangeOfString:iTetTeamWinlistEntryCharacter
								   options:(NSAnchoredSearch | NSCaseInsensitiveSearch)].location != NSNotFound)
		{
			[winlistEntries addObject:[iTetWinlistEntry teamEntryWithName:[[entryComponents objectAtIndex:0] substringFromIndex:1]
																	score:[[entryComponents objectAtIndex:1] integerValue]]];
		}
		else
			NSLog(@"WARNING: malformed winlist entry: %@", entryToken);
	}
	
	[self setWinlist:winlistEntries];
}

#pragma mark -
#pragma mark Accessors

@synthesize winlist;

@end
