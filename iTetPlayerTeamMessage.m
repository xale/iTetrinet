//
//  iTetPlayerTeamMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetPlayerTeamMessage.h"
#import "NSString+ASCIIData.h"

@implementation iTetPlayerTeamMessage

+ (id)playerTeamMessageWithPlayerNumber:(NSInteger)number
							   teamName:(NSString*)nameOfTeam
{
	return [[[self alloc] initWithPlayerNumber:number
									  teamName:nameOfTeam] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)number
				  teamName:(NSString*)nameOfTeam
{
	messageType = playerTeamMessage;
	
	playerNumber = number;
	teamName = [nameOfTeam copy];
	
	return self;
}

- (void)dealloc
{
	[teamName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark iTetIncomingMessage Protocol Initializer

- (id)initWithMessageData:(NSData*)messageData
{
	messageType = playerTeamMessage;
	
	// Convert the message data to a string
	NSString* rawMessage = [NSString stringWithASCIIData:messageData];
	
	// Split into space-delimited tokens
	NSArray* messageTokens = [rawMessage componentsSeparatedByString:@" "];
	
	// Parse the first token as the player number
	playerNumber = [[messageTokens objectAtIndex:0] integerValue];
	
	// Treat the second token as the player's team name
	teamName = [[messageTokens objectAtIndex:1] retain];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const iTetPlayerTeamMessageFormat =	@"team %d %@";

- (NSData*)rawMessageData
{
	NSString* rawMessage = [NSString stringWithFormat:iTetPlayerTeamMessageFormat, [self playerNumber], [self teamName]];
	
	return [rawMessage dataUsingEncoding:NSASCIIStringEncoding
					allowLossyConversion:YES];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize teamName;

@end
