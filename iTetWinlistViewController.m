//
//  iTetWinlistViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//

#import "iTetWinlistViewController.h"
#import "iTetWinlistEntry.h"

@implementation iTetWinlistViewController

static unichar const iTetPlayerEntryCharacter = 'p';
static unichar const iTetTeamEntryCharacter = 't';

- (void)parseWinlist:(NSArray*)winlistTokens
{
	NSMutableArray* playerEntries = [NSMutableArray array];
	NSMutableArray* teamEntries = [NSMutableArray array];
	
	// Iterate through the list of players and teams
	NSArray* entryComponents;
	for (NSString* entryToken in winlistTokens)
	{
		// Divide the token at the semicolon delimiter
		entryComponents = [entryToken componentsSeparatedByString:@";"];
		if ([entryComponents count] < 2)
		{
			NSLog(@"WARNING: malformed winlist entry: %@", entryToken);
			continue;
		}
		
		// Create the entry
		iTetWinlistEntry* entry = [iTetWinlistEntry entryWithName:[[entryComponents objectAtIndex:0] substringFromIndex:1]
										    score:[[entryComponents objectAtIndex:1] integerValue]];
		
		// Determine if this entry represents a player or a team
		unichar firstChar = [entryToken characterAtIndex:0];
		if (firstChar == iTetPlayerEntryCharacter)
			[playerEntries addObject:entry];
		else if (firstChar == iTetTeamEntryCharacter)
			[teamEntries addObject:entry];
		else
			NSLog(@"WARNING: malformed winlist entry: %@", entryToken);
	}
	
	[self setPlayersWinlist:[playerEntries copy]];
	[self setTeamsWinlist:[teamEntries copy]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playersWinlist;
@synthesize teamsWinlist;

@end
