//
//  iTetWinlistEntry.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetWinlistEntry.h"

NSString* const iTetPlayerWinlistEntryTag =	@"p";
NSString* const iTetTeamWinlistEntryTag =	@"t";

@implementation iTetWinlistEntry

+ (id)entryWithWinlistMessageToken:(NSString*)token
{
	// Divide the token at the semicolon delimiter, checking that it exists
	NSArray* entryComponents = [token componentsSeparatedByString:@";"];
	if ([entryComponents count] < 2)
		return nil;
	
	NSString* name = [entryComponents objectAtIndex:0];
	NSInteger score = [[entryComponents objectAtIndex:1] integerValue];
	
	// Determine if this entry represents a player or a team
	if ([name rangeOfString:iTetPlayerWinlistEntryTag
					options:(NSAnchoredSearch | NSCaseInsensitiveSearch)].location != NSNotFound)
	{
		return [self playerEntryWithName:[name substringFromIndex:1]
								   score:score];
	}
	else if ([name rangeOfString:iTetTeamWinlistEntryTag
						 options:(NSAnchoredSearch | NSCaseInsensitiveSearch)].location != NSNotFound)
	{
		return [self teamEntryWithName:[name substringFromIndex:1]
								 score:score];
	}
	
	// Malformed entry
	return nil;
}

+ (id)playerEntryWithName:(NSString *)name
					score:(NSInteger)score
{
	return [[[self alloc] initWithName:name
								 score:score
								isTeam:NO] autorelease];
}

+ (id)teamEntryWithName:(NSString*)name
				  score:(NSInteger)score
{
	return [[[self alloc] initWithName:name
								 score:score
								isTeam:YES] autorelease];
}

- (id)initWithName:(NSString*)name
			 score:(NSInteger)score
			isTeam:(BOOL)isTeam
{
	entryName = [name copy];
	entryScore = score;
	teamEntry = isTeam;
	
	return self;
}

- (void)dealloc
{
	[entryName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Data

- (NSString*)messageToken
{
	return [NSString stringWithFormat:@"%@%@;%ld", ([self isTeamEntry] ? iTetTeamWinlistEntryTag : iTetPlayerWinlistEntryTag), [self entryName], (long)[self entryScore]];
}

#pragma mark -
#pragma mark Accessors

@synthesize entryName;
@synthesize entryScore;
@synthesize teamEntry;

@end
