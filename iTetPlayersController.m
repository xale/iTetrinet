//
//  iTetPlayersController.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/10.
//

#import "iTetPlayersController.h"
#import "iTetPlayer.h"
#import "iTetLocalPlayer.h"

@implementation iTetPlayersController

#define iTetCheckPlayerNumber(n) NSParameterAssert(((n) > 0) && ((n) <= ITET_MAX_PLAYERS))

- (void)setLocalPlayerNumber:(NSInteger)number
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Check that the assigned slot is not already occupied
	if ([self playerNumber:number] != nil)
	{
		NSLog(@"WARNING: local player assigned to occupied player slot");
		playerCount--;
	}
	
	// Check if our player already exists; if so, this is a move operation
	if ([self localPlayer] != nil)
	{
		// Clear the old location in the players array
		[players replaceObjectAtIndex:([[self localPlayer] playerNumber] - 1)
						   withObject:[NSNull null]];
		
		// Change the local player's number
		[[self localPlayer] setPlayerNumber:number];
		
		// Move to the new location in the players array
		[players replaceObjectAtIndex:(number - 1)
						   withObject:[self localPlayer]];
		
		// No need to notify game controller; field assignment will not change
	}
	else
	{
		// Create the local player
		[self setLocalPlayer:[iTetLocalPlayer playerWithNickname:[[networkController currentServer] nickname]
														  number:number
														teamName:[[networkController currentServer] playerTeam]]];
		
		// Place the player in the players array
		[players replaceObjectAtIndex:(number - 1)
						   withObject:[self localPlayer]];
		
		// Update player count
		playerCount++;
	}
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)addPlayerWithNumber:(NSInteger)number
				   nickname:(NSString*)nick
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Check that the slot is not already occupied
	if ([self playerNumber:number] != nil)
	{
		// (some servers echo our own player-join event back to us; ignore this and don't add a new player)
		if (number == [localPlayer playerNumber])
			return;
		
		NSLog(@"WARNING: new player assigned to occupied player slot");
		playerCount--;
	}
	
	// Create the new player
	[players replaceObjectAtIndex:(number - 1)
					   withObject:[iTetPlayer playerWithNickname:nick
														  number:number]];
	
	// Update player count
	playerCount++;
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)removePlayerNumber:(NSInteger)number
{
	// Sanity checks
	iTetCheckPlayerNumber(number);
	if ([self playerNumber:number] == nil)
	{
		NSLog(@"WARNING: attempt to remove player in empty player slot");
		return;
	}
	
	[self willChangeValueForKey:@"playerList"];
	
	// Remove the player
	[players replaceObjectAtIndex:(number - 1)
					   withObject:[NSNull null]];
	
	// Update player count
	playerCount--;
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)removeAllPlayers
{
	// Remove the local player
	[self setLocalPlayer:nil];
	
	[self willChangeValueForKey:@"playerList"];
	
	// Remove all players in the players array
	for (NSInteger i = 0; i < ITET_MAX_PLAYERS; i++)
	{
		[players replaceObjectAtIndex:i
						   withObject:[NSNull null]];
	}
	
	// Reset the player count
	playerCount = 0;
	
	[self didChangeValueForKey:@"playerList"];
}

- (NSArray*)playerList
{
	return [players filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", [NSNull null]]];
}

- (NSNumber*)averagePlayerLevel
{
	NSInteger total = 0, count = 0;
	for (iTetPlayer* player in [self playerList])
	{
		if ([player isPlaying])
		{	
			total += [player level];
			count++;
		}
	}
	
	if (count > 0)
		return [NSNumber numberWithInteger:(total / count)];
	
	return nil;
}

@synthesize localPlayer;

-(iTetPlayer*)remotePlayer1
{
	return [self remotePlayerNumber:1];
}
-(iTetPlayer*)remotePlayer2
{
	return [self remotePlayerNumber:2];
}
-(iTetPlayer*)remotePlayer3
{
	return [self remotePlayerNumber:3];
}
-(iTetPlayer*)remotePlayer4
{
	return [self remotePlayerNumber:4];
}
-(iTetPlayer*)remotePlayer5
{
	return [self remotePlayerNumber:5];
}
- (iTetPlayer*)remotePlayerNumber:(NSInteger)n
{	
	// Shift index to account for the local player's number
	if ([[self localPlayer] playerNumber] > n)
		n--;
	
	// Return the player at that index, or nil
	id player = [players objectAtIndex:n];
	if (player == [NSNull null])
		return nil;
	
	return (iTetPlayer*)player;
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
	NSSet* keys = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key rangeOfString:@"remotePlayer"].location != NSNotFound)
	{
		keys = [keys setByAddingObjectsFromSet:[NSSet setWithObjects:@"playerList", @"localPlayer", nil]];
	}
	else if ([key isEqualToString:@"averagePlayerLevel"])
	{
		keys = [keys setByAddingObjectsFromSet:[NSSet setWithObjects:@"localPlayer.level", @"remotePlayer1.level", @"remotePlayer2.level", @"remotePlayer3.level", @"remotePlayer4.level", @"remotePlayer5.level", @"localPlayer.isPlaying", @"remotePlayer1.isPlaying", @"remotePlayer2.isPlaying", @"remotePlayer3.isPlaying", @"remotePlayer4.isPlaying", @"remotePlayer5.isPlaying", nil]];
	}
	
	return keys;
}

- (iTetPlayer*)playerNumber:(NSInteger)number
{
	iTetCheckPlayerNumber(number);
	
	id player = [players objectAtIndex:(number - 1)];
	if (player == [NSNull null])
		return nil;
	
	return (iTetPlayer*)player;
}

- (iTetPlayer*)operatorPlayer
{
	// Return the player with the lowest player number (first player in the array)
	for (NSInteger index = 0; index < ITET_MAX_PLAYERS; index++)
	{
		if (players[index] != [NSNull null])
			return players[index];
	}
	
	return nil;
}

NSString* const iTetServerPlayerNamePlaceholder = @"SERVER";

- (NSString*)playerNameForNumber:(NSInteger)number
{
	if (number == 0)
		return iTetServerPlayerNamePlaceholder;
	else
		return [[self playerNumber:number] nickname];
}

@end
