//
//  iTetPlayerTeamMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/22/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayerTeamMessage.h"
#import "NSArray+Subranges.h"

NSString* const iTetPlayerTeamMessageTag =	@"team";

@implementation iTetPlayerTeamMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat the second token as the player number
	playerNumber = [[tokens objectAtIndex:1] integerValue];
	
	// Treat the remaining tokens, if present, as the team name
	if ([tokens count] > 2)
		playerTeamName = [[[tokens subarrayFromIndex:2] componentsJoinedByString:@" "] copy];
	
	return self;
}

+ (id)messageWithPlayerNumber:(NSInteger)number
					 teamName:(NSString*)teamName
{
	return [[[self alloc] initWithPlayerNumber:number
									  teamName:teamName] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)number
				  teamName:(NSString*)teamName
{
	if (!(self = [super init]))
		return nil;
	
	playerNumber = number;
	playerTeamName = [teamName copy];
	
	return self;
}

- (void)dealloc
{
	[playerTeamName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %ld %@", iTetPlayerTeamMessageTag, (long)[self playerNumber], [self playerTeamName]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize playerTeamName;

@end
