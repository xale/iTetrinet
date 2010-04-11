//
//  iTetChannelInfo.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/23/09.
//

#import "iTetChannelInfo.h"

@implementation iTetChannelInfo

+ (id)channelInfoWithName:(NSString*)name
			  description:(NSAttributedString*)desc
		   currentPlayers:(NSInteger)playerCount
			   maxPlayers:(NSInteger)max
					state:(iTetGameplayState)gameState
{
	return [[[self alloc] initWithName:name
						   description:desc
						currentPlayers:playerCount
							maxPlayers:max
								 state:gameState] autorelease];
}

- (id)initWithName:(NSString*)name
	   description:(NSAttributedString*)desc
	currentPlayers:(NSInteger)playerCount
		maxPlayers:(NSInteger)max
			 state:(iTetGameplayState)gameState
{
	channelName = [name copy];
	channelDescription = [desc copy];
	currentPlayers = playerCount;
	maxPlayers = max;
	channelState = gameState;
	
	return self;
}

- (void)dealloc
{
	[channelName release];
	[channelDescription release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize channelName;
@synthesize channelDescription;

- (NSString*)players
{
	return [NSString stringWithFormat:@"%d / %d", currentPlayers, maxPlayers];
}

@synthesize channelState;

@end
