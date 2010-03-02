//
//  iTetWinlistEntry.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//

#import "iTetWinlistEntry.h"

@implementation iTetWinlistEntry

+ (id)playerEntryWithName:(NSString *)entryName
					score:(NSInteger)entryScore
{
	return [[[self alloc] initWithName:entryName
								 score:entryScore
								isTeam:NO] autorelease];
}

+ (id)teamEntryWithName:(NSString*)entryName
				  score:(NSInteger)entryScore
{
	return [[[self alloc] initWithName:entryName
								 score:entryScore
								isTeam:YES] autorelease];
}

- (id)initWithName:(NSString*)entryName
			 score:(NSInteger)entryScore
			isTeam:(BOOL)isTeam
{
	name = [entryName copy];
	score = entryScore;
	team = isTeam;
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize name;
@synthesize score;
@synthesize team;

@end
