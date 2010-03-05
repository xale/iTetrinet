//
//  iTetWinlistViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//

#import "iTetWinlistViewController.h"
#import "iTetWinlistEntry.h"

@implementation iTetWinlistViewController

static const unichar iTetPlayerEntryCharacter = 'p';
static const unichar iTetTeamEntryCharacter = 't';

- (void)parseWinlist:(NSArray*)winlistTokens
{
	NSMutableArray* winlistEntries = [NSMutableArray array];
	
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
		
		// Determine if this entry represents a player or a team
		unichar firstChar = [entryToken characterAtIndex:0];
		if (firstChar == iTetPlayerEntryCharacter)
		{
			[winlistEntries addObject:[iTetWinlistEntry playerEntryWithName:[[entryComponents objectAtIndex:0] substringFromIndex:1]
																	  score:[[entryComponents objectAtIndex:1] integerValue]]];
		}
		else if (firstChar == iTetTeamEntryCharacter)
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
