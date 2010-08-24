//
//  iTetPlayersController.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/15/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetPlayersController.h"

#import "iTetWindowController.h"
#import "iTetNetworkController.h"

#import "iTetMessage.h"
#import "NSDictionary+AdditionalTypes.h"

#import "iTetServerInfo.h"

#import "iTetNotifications.h"

#import "iTetPlayer.h"
#import "iTetLocalPlayer.h"
#import "iTetServerPlayer.h"

@implementation iTetPlayersController

- (id)init
{
	// Create the players array (initially filled with NSNull placeholders)
	players = [[NSMutableArray alloc] initWithCapacity:ITET_MAX_PLAYERS];
	for (NSInteger i = 0; i < ITET_MAX_PLAYERS; i++)
		[players addObject:[NSNull null]];
	
	// Create a placeholder "server player"
	serverPlayer = [[iTetServerPlayer alloc] init];
	
	return self;
}

- (void)dealloc
{
	[players release];
	[localPlayer release];
	[serverPlayer release];
	[lastWinningPlayer release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)changeTeamName:(id)sender
{
	// Run the "change team name" sheet
	[NSApp beginSheet:teamNameSheet
	   modalForWindow:[windowController window]
	    modalDelegate:self
	   didEndSelector:@selector(changeTeamNameSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (IBAction)closeTeamNameSheet:(id)sender
{
	[NSApp endSheet:teamNameSheet
		 returnCode:[sender tag]];
}

- (void)changeTeamNameSheetDidEnd:(NSWindow*)sheet
					   returnCode:(NSInteger)returnCode
					  contextInfo:(void*)contextInfo
{
	// If the user pressed "cancel" do nothing
	if (returnCode == 0)
	{
		// Clear the text field
		[teamNameField setStringValue:[NSString string]];
		
		[sheet orderOut:self];
		return;
	}
	
	// Otherwise, get the team name from the field
	NSString* newTeam = [teamNameField stringValue];
	[sheet orderOut:self];
	
	// Check that the name is not nil, and remove any leading or trailing spaces
	if (newTeam == nil)
		newTeam = [NSString string];
	newTeam = [iTetServerInfo serverSanitizedTeamName:newTeam];
	
	// Change the local player's team name
	[localPlayer setTeamName:newTeam];
	
	// Send the team name to the server
	iTetMessage* message = [iTetMessage messageWithMessageType:playerTeamMessage];
	[[message contents] setInteger:[localPlayer playerNumber]
							forKey:iTetMessagePlayerNumberKey];
	[[message contents] setObject:newTeam
						   forKey:iTetMessagePlayerTeamNameKey];
	[networkController sendMessage:message];
}

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Determine the element's action
	SEL action = [item action];
	
	if (action == @selector(changeTeamName:))
	{
		return ([networkController connectionOpen] && ![localPlayer isPlaying]);
	}
	
	return YES;
}

#pragma mark -
#pragma mark Accessors

- (void)createLocalPlayerWithNumber:(NSInteger)number
						   nickname:(NSString*)nickname
						   teamName:(NSString*)teamName
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	// Check that the assigned slot is not already occupied
	NSAssert2(([self playerNumber:number] == nil),@"local player assigned to occupied player slot: %d (%@)", number, [self playerNumber:number]);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Create the local player
	[self setLocalPlayer:[iTetLocalPlayer playerWithNickname:nickname
													  number:number
													teamName:teamName]];
	
	// Place the player in the players array
	[players replaceObjectAtIndex:(number - 1)
					   withObject:[self localPlayer]];
	
	// Update player count
	playerCount++;
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)changeLocalPlayerNumber:(NSInteger)number
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	// Check that the assigned slot is not already occupied
	NSAssert2(([self playerNumber:number] == nil), @"local player assigned to occupied player slot: %d (%@)", number, [self playerNumber:number]);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Clear the local player's old slot
	[players replaceObjectAtIndex:([localPlayer playerNumber] - 1)
					   withObject:[NSNull null]];
	
	// Move to the new slot
	[players replaceObjectAtIndex:(number - 1)
					   withObject:localPlayer];
	
	// Change the local player's number
	[localPlayer setPlayerNumber:number];
	
	// Playercount unchanged
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)addPlayerWithNumber:(NSInteger)number
				   nickname:(NSString*)nick
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	// Check that the slot is not already occupied
	NSAssert3(([self playerNumber:number] == nil), @"new player '%@' assigned to occupied player slot: %d (%@)", nick, number, [self playerNumber:number]);
	
	[self willChangeValueForKey:@"playerList"];
	
	// Create the new player
	[players replaceObjectAtIndex:(number - 1)
					   withObject:[iTetPlayer playerWithNickname:nick
														  number:number]];
	
	// Update player count
	playerCount++;
	
	[self didChangeValueForKey:@"playerList"];
	
	// Post a notification
	[[NSNotificationCenter defaultCenter] postNotificationName:iTetPlayerJoinedEventNotificationName
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:nick
																						   forKey:iTetNotificationPlayerNicknameKey]];
}

- (void)setTeamName:(NSString*)teamName
	forPlayerNumber:(NSInteger)number
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	// Find the player in question
	iTetPlayer* player = [self playerNumber:number];
	
	// Post a notification of the team change
	NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [player nickname], iTetNotificationPlayerNicknameKey,
							  [player teamName], iTetNotificationOldTeamNameKey,
							  teamName, iTetNotificationNewTeamNameKey,
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:iTetPlayerTeamChangeEventNotificationName
														object:self
													  userInfo:infoDict];
	

	[self willChangeValueForKey:@"playerList"];
	
	// Change the player's team
	[player setTeamName:teamName];
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)setLevel:(NSInteger)level
 forPlayerNumber:(NSInteger)number
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	[[self playerNumber:number] setLevel:level];
}

- (void)setGameLostForPlayerNumber:(NSInteger)number
{
	// Sanity check
	iTetCheckPlayerNumber(number);
	
	// Change the player's "playing" status
	[[self playerNumber:number] setPlaying:NO];
}

- (void)setGameStartedForAllRemotePlayers
{
	// Iterate through all objects in the player list
	for (id player in players)
	{
		// Only set to "playing" if the object is an iTetPlayer (skips NSNull objects and the iTetLocalPlayer subclass)
		if ([player isMemberOfClass:[iTetPlayer class]])
			[player setPlaying:YES];
	}
}

- (void)kickPlayerNumber:(NSInteger)playerNumber
{
	// Sanity checks
	iTetCheckPlayerNumber(playerNumber);
	NSAssert1(([self playerNumber:playerNumber] != nil), @"attempt to kick player in empty player slot: %d", playerNumber);
	
	// Get the player in question
	iTetPlayer* player = [self playerNumber:playerNumber];
	
	// Mark the player as "kicked", so that we don't have to report when the server disconnects them
	[player setKicked:YES];
	
	// Post a notification
	NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
						  [player nickname], iTetNotificationPlayerNicknameKey,
						  [NSNumber numberWithBool:[player isLocalPlayer]], iTetNotificationIsLocalPlayerKey,
						  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:iTetPlayerKickedEventNotificationName
														object:self
													  userInfo:info];
}

- (void)removePlayerNumber:(NSInteger)playerNumber
{
	// Sanity checks
	iTetCheckPlayerNumber(playerNumber);
	NSAssert1(([self playerNumber:playerNumber] != nil), @"attempt to remove player in empty player slot: %d", playerNumber);
	
	// Get the player in question
	iTetPlayer* player = [self playerNumber:playerNumber];
	
	// If the player hasn't been kicked, post a "player left" notification
	if (![player isKicked])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:iTetPlayerLeftEventNotificationName
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:[[self playerNumber:playerNumber] nickname]
																							   forKey:iTetNotificationPlayerNicknameKey]];
	}
	
	[self willChangeValueForKey:@"playerList"];
	
	// Remove the player
	[players replaceObjectAtIndex:(playerNumber - 1)
					   withObject:[NSNull null]];
	
	// Update player count
	playerCount--;
	
	[self didChangeValueForKey:@"playerList"];
}

- (void)removeAllPlayers
{
	// Remove the local player, and the last designated winner
	[self setLocalPlayer:nil];
	[self setLastWinningPlayer:nil];
	
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
@synthesize serverPlayer;
@synthesize lastWinningPlayer;

- (iTetPlayer*)operatorPlayer
{
	// Return the player with the lowest player number (first player in the array)
	for (NSInteger index = 0; index < ITET_MAX_PLAYERS; index++)
	{
		id player = [players objectAtIndex:index];
		if ([player isKindOfClass:[iTetPlayer class]])
			return (iTetPlayer*)player;
	}
	
	return nil;
}

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
	else if ([key isEqualToString:@"operatorPlayer"])
	{
		keys = [keys setByAddingObjectsFromSet:[NSSet setWithObjects:@"playerList", @"localPlayer", nil]];
	}
	else if ([key isEqualToString:@"averagePlayerLevel"])
	{
		keys = [keys setByAddingObjectsFromSet:[NSSet setWithObjects:@"localPlayer.level", @"remotePlayer1.level", @"remotePlayer2.level", @"remotePlayer3.level", @"remotePlayer4.level", @"remotePlayer5.level", @"localPlayer.isPlaying", @"remotePlayer1.isPlaying", @"remotePlayer2.isPlaying", @"remotePlayer3.isPlaying", @"remotePlayer4.isPlaying", @"remotePlayer5.isPlaying", nil]];
	}
	
	return keys;
}

#define iTetCheckPlayerOrServerNumber(n) NSParameterAssert(((n) >= 0) && ((n) <= ITET_MAX_PLAYERS))

- (iTetPlayer*)playerNumber:(NSInteger)number
{
	iTetCheckPlayerOrServerNumber(number);
	
	if (number == 0)
		return serverPlayer;
	
	id player = [players objectAtIndex:(number - 1)];
	if (player == [NSNull null])
		return nil;
	
	return (iTetPlayer*)player;
}

@end
