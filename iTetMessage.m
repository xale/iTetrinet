//
//  iTetMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/2/10.
//

#import "iTetMessage.h"

NSDictionary* iTetMessageDesignations = nil;
NSString* const iTetNoConnectingMessageDesignation =			@"noconnecting";

NSString* const iTetPlayerNumberMessageDesignation =			@"playernum";	// Tetrinet protocol
NSString* const iTetTetrifastPlayerNumberMessageDesignation =	@")#)(!@(*3";	// Tetrifast protocol
NSString* const iTetPlayerJoinMessageDesignation =				@"playerjoin";
NSString* const iTetPlayerLeaveMessageDesignation =				@"playerleave";
NSString* const iTetPlayerTeamMessageDesignation =				@"team";
NSString* const iTetWinlistMessageDesignation =					@"winlist";

NSString* const iTetPLineTextMessageDesignation =				@"pline";
NSString* const iTetPLineActionMessageDesignation =				@"plineact";
NSString* const iTetGameChatMessageDesignation =				@"gmsg";

NSString* const iTetNewGameMessageDesignation =					@"newgame";		// Tetrinet protocol
NSString* const iTetTetrifastNewGameMessageDesignation =		@"*******";		// Tetrifast protocol
NSString* const iTetInGameMessageDesignation =					@"ingame";
NSString* const iTetPauseResumeGameMessageDesignation =			@"pause";
NSString* const iTetEndGameMessageDesignation =					@"endgame";

NSString* const iTetFieldstringMessageDesignation =				@"f";
NSString* const iTetLevelUpdateMessageDesignation =				@"lvl";
NSString* const iTetSpecialMessageDesignation =					@"sb";
NSString* const iTetPlayerLostMessageDesignation =				@"playerlost";
NSString* const iTetPlayerWonMessageDesignation =				@"playerwon";

#pragma mark -
#pragma mark Private Class Methods

@interface iTetMessage (PrivateMethods)

+ (NSDictionary*)messageDesignationsDictionary;

@end

@implementation iTetMessage (PrivateMethods)

+ (NSDictionary*)messageDesignationsDictionary
{
	// Create a lookup-table of message designation-strings to message types
	NSMutableDictionary* messages = [NSMutableDictionary dictionary];
	
	// Connection-handling messages
	[messages setObject:[NSNumber numberWithInt:noConnectingMessage]
				 forKey:iTetNoConnectingMessageDesignation];
	
	// Player-status messages
	[messages setObject:[NSNumber numberWithInt:playerNumberMessage]
				 forKey:iTetPlayerNumberMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:playerNumberMessage]
				 forKey:iTetTetrifastPlayerNumberMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:playerJoinMessage]
				 forKey:iTetPlayerJoinMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:playerLeaveMessage]
				 forKey:iTetPlayerLeaveMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:playerTeamMessage]
				 forKey:iTetPlayerTeamMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:winlistMessage]
				 forKey:iTetWinlistMessageDesignation];
	
	// Chat messages
	[messages setObject:[NSNumber numberWithInt:plineChatMessage]
				 forKey:iTetPLineTextMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:plineActionMessage]
				 forKey:iTetPLineActionMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:gameChatMessage]
				 forKey:iTetGameChatMessageDesignation];
	
	// Game-state messages
	[messages setObject:[NSNumber numberWithInt:newGameMessage]
				 forKey:iTetNewGameMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:newGameMessage]
				 forKey:iTetTetrifastNewGameMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:inGameMessage]
				 forKey:iTetInGameMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:pauseResumeGameMessage]
				 forKey:iTetPauseResumeGameMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:endGameMessage]
				 forKey:iTetEndGameMessageDesignation];
	// Gameplay messages
	[messages setObject:[NSNumber numberWithInt:fieldstringMessage]
				 forKey:iTetFieldstringMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:levelUpdateMessage]
				 forKey:iTetLevelUpdateMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:specialMessage]
				 forKey:iTetSpecialMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:playerLostMessage]
				 forKey:iTetPlayerLostMessageDesignation];
	[messages setObject:[NSNumber numberWithInt:playerWonMessage]
				 forKey:iTetPlayerWonMessageDesignation];
	
	return messages;
}

@end

@implementation iTetMessage

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

#pragma mark -
#pragma mark Accessors

+ (NSDictionary*)messageDesignations
{
	@synchronized(self)
	{
		if (iTetMessageDesignations == nil)
		{
			iTetMessageDesignations = [[self messageDesignationsDictionary] copy];
		}
	}
	
	return iTetMessageDesignations;
}

@synthesize messageType;

@end
