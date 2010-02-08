//
//  iTetWinlistEntry.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//

#import "iTetWinlistEntry.h"

@implementation iTetWinlistEntry

+ (id)entryWithName:(NSString*)entryName
		  score:(NSInteger)entryScore
{
	return [[[self alloc] initWithName:entryName
					     score:entryScore] autorelease];
}

- (id)initWithName:(NSString*)entryName
		 score:(NSInteger)entryScore
{
	name = [entryName copy];
	score = entryScore;
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@synthesize name;
@synthesize score;

@end
