//
//  iTetNetworkController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetNetworkController.h"

#import <netdb.h>

#import "iTetMainWindowController.h"
#import "iTetPlayersController.h"
#import "iTetGameViewController.h"
#import "iTetChatViewController.h"
#import "iTetChannelsViewController.h"
#import "iTetWinlistViewController.h"
#import "iTetGrowlController.h"

#import "AsyncSocket.h"
#import "iTetMessage.h"

#import "iTetLocalPlayer.h"
#import "iTetField.h"
#import "iTetGameRules.h"

#import "iTetUserDefaults.h"
#import "iTetCommonLocalizations.h"

#import "NSData+SingleByte.h"
#import "NSData+Subdata.h"
#import "NSDictionary+AdditionalTypes.h"

#ifdef _ITETRINET_DEBUG
#import "NSString+MessageData.h"
#import "iTetTextAttributes.h"
#endif

NSString* const iTetNetworkErrorDomain = @"iTetNetworkError";
#define iTetNetworkTerminatorCharacter	(0xFF)
#define iTetGameNetworkPort				(31457)

@interface iTetNetworkController (Private)

- (void)messageReceived:(iTetMessage*)message;
- (void)handleError:(NSError*)error;

- (void)setConnectionState:(iTetConnectionState)newState;

@end

@implementation iTetNetworkController

+ (void)initialize
{
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSNumber numberWithDouble:5.0]
				 forKey:iTetConnectionTimeoutPrefKey];
	[defaults setBool:YES
			   forKey:iTetAutoSwitchChatOnConnectPrefKey];
	[defaults setBool:YES
			   forKey:iTetAutoSwitchChatAfterGamePrefKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)init
{
	gameSocket = [[AsyncSocket alloc] initWithDelegate:self];
	
	return self;
}

- (void)dealloc
{
	// Disconnect
	[self disconnect];
	
	// Release socket and server data
	[gameSocket release];
	[currentServerAddress release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Interface Actions

#define iTetDisconnectWithGameInProgressAlertInformativeText	NSLocalizedStringFromTable(@"A game is currently in progress. Are you sure you want to disconnect from the server?", @"NetworkController", @"Informative text on alert displayed when the user attempts to disconnect from a server while participating in a game")
#define iTetDisconnectWithGameInProgressConfirmButtonTitle		NSLocalizedStringFromTable(@"Forfeit and Disconnect", @"NetworkController", @"Title of button on 'disconnect with game in progress?' alert that allows the user to stop playing and disconnect")

- (IBAction)openCloseConnection:(id)sender
{
	switch ([self connectionState])
	{
			// If there is already a connection open, disconnect
		case connected:
		{
			// If local player is playing a game, ask the user before disconnecting
			if ([[playersController localPlayer] isPlaying])
			{
				// Create an alert
				NSAlert* alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:iTetGameInProgressAlertTitle];
				[alert setInformativeText:iTetDisconnectWithGameInProgressAlertInformativeText];
				[alert addButtonWithTitle:iTetDisconnectWithGameInProgressConfirmButtonTitle];
				[alert addButtonWithTitle:iTetContinuePlayingButtonTitle];
				
				// Run the alert as a sheet
				[alert beginSheetModalForWindow:[windowController window]
								  modalDelegate:self
								 didEndSelector:@selector(disconnectWithGameInProgressAlertDidEnd:returnCode:contextInfo:)
									contextInfo:NULL];
				
				break;
			}
			
			// Otherwise, just disconnect from the server
			[self disconnect];
			
			break;
		}
			
			// If we are attempting to open a connection, abort the attempt
		case connecting:
		case login:
		{
			// Change connection state
			[self setConnectionState:canceled];
			
			if ([gameSocket isConnected])
			{
				// If the socket has already opened a connection to the server, disconnect
				[self disconnect];
			}
			else
			{
				// Otherwise, reset the connection state
				[self setConnectionState:disconnected];
			}
			
			break;
		}
			
			// If we are not connected, open the server browser for a new connection
		case disconnected:
		{
			// Open the server browser
			[windowController showServerBrowser:sender];
			
			break;
		}
			
		case canceled:
		case connectionError:
		case disconnecting:
		{
			NSString* excDesc = [NSString stringWithFormat:@"NetworkController -openCloseConnection: called with invalid connection state: %d", [self connectionState]];
			NSException* invalidStateException = [NSException exceptionWithName:NSInternalInconsistencyException
																		 reason:excDesc
																	   userInfo:nil];
			@throw invalidStateException;
		}
	}
}

- (void)disconnectWithGameInProgressAlertDidEnd:(NSAlert*)alert
									 returnCode:(NSInteger)returnCode
									contextInfo:(void*)contextInfo
{
	// If the user pressed "continue playing", do nothing
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	// Disconnect from the server
	[self disconnect];
}

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Determine the element's action
	SEL action = [item action];
	
	if (action == @selector(openCloseConnection:))
	{
		switch ([self connectionState])
		{
			case canceled:
			case connectionError:
			case disconnecting:
				return NO;
				
			default:
				break;
		}
	}
	
	return YES;
}

#pragma mark -
#pragma mark Connecting

- (void)connectToServerAddress:(NSString*)serverAddress
					  protocol:(iTetProtocolType)gameProtocol
					   version:(iTetGameVersion)gameVersion
				playerNickname:(NSString*)nickname
				playerTeamName:(NSString*)teamName
{
	// Hold onto the server info
	currentServerAddress = [serverAddress copy];
	currentServerProtocol = gameProtocol;
	currentGameVersion = gameVersion;
	connectingPlayer = [[iTetLocalPlayer alloc] initWithNickname:nickname
														teamName:teamName];
	
	// Change the connection state
	[self setConnectionState:connecting];
	
	// Attempt to open a connection to the server
	NSError* error;
	BOOL success = [gameSocket connectToHost:currentServerAddress
									  onPort:iTetGameNetworkPort
									   error:&error];
	
	// If the socket refuses to attempt a connection, determine why
	if (!success)
	{
		[self handleError:error];
		return;
	}
	
	// Otherwise, enqueue an initial read operation, with a timeout
	[gameSocket readDataToData:[NSData dataWithByte:iTetNetworkTerminatorCharacter]
				   withTimeout:[[NSUserDefaults standardUserDefaults] doubleForKey:iTetConnectionTimeoutPrefKey]
						   tag:0];
}

- (void)onSocket:(AsyncSocket*)socket
didConnectToHost:(NSString*)hostname
			port:(UInt16)port
{
	// FIXME: oh god the brokens
	if ([hostname isEqualToString:@"::1"])
		hostname = @"127.0.0.1";
	
	// Create a server login message
	iTetMessageType loginMessageType = ((currentServerProtocol == tetrinetProtocol) ? tetrinetLoginMessage : tetrifastLoginMessage);
	iTetMessage* message = [iTetMessage messageWithMessageType:loginMessageType];
	[[message contents] setObject:[connectingPlayer nickname]
						   forKey:iTetMessagePlayerNicknameKey];
	[[message contents] setObject:hostname
						   forKey:iTetMessageServerAddressKey];
	[[message contents] setInt:currentGameVersion
						forKey:iTetMessageGameVersionKey];
	
	// Send the login message
	[self sendMessage:message];
	
	// Change the connection state
	[self setConnectionState:login];
}

#pragma mark -
#pragma mark Disconnecting

- (void)disconnect
{
	// If we are already disconnected, ignore
	if (![gameSocket isConnected])
		return;
	
	// If there is a game in progress, end it
	if ([gameController gameInProgress])
		[gameController endGame];
	
	// Change connection status, if necessary
	if ([self connectionOpen])
		[self setConnectionState:disconnecting];
	
	// Tell the socket to disconnect
	[gameSocket disconnectAfterWriting];
}

- (void)onSocket:(AsyncSocket*)socket
willDisconnectWithError:(NSError*)error
{
	// If there is a game in progress, end it
	if ([gameController gameInProgress])
		[gameController endGame];
	
	// If an error occurred, handle as appropriate
	if (error != nil)
		[self handleError:error];
}

- (void)onSocketDidDisconnect:(AsyncSocket*)socket
{
	// Change our connection state
	[self setConnectionState:disconnected];
	
	// Remove all players from the players controller
	[playersController removeAllPlayers];
	
	// Tell the channels view controller to stop updating the channel list
	[channelsController stopQueriesAndDisconnect];
}

#pragma mark -
#pragma mark Reads/Writes

- (void)sendMessage:(iTetMessage*)message
{
#ifdef _ITETRINET_DEBUG
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableMessageLogging"])
	{
		NSString* messageString = [NSString stringWithMessageData:[message rawMessageData]];
		NSMutableString* debugString = [NSMutableString string];
		unichar character;
		for (NSUInteger i = 0; i < [messageString length]; i++)
		{
			character = [messageString characterAtIndex:i];
			if ([[iTetTextAttributes chatTextAttributeCharacterSet] characterIsMember:character])
				[debugString appendFormat:@"<\\%02u>", (int)character];
			else
				[debugString appendFormat:@"%C", character];
		}
		NSLog(@"DEBUG:    sending outgoing message: '%@'", debugString);
	}
#endif
	
	// Append the delimiter byte and send the message
	[gameSocket writeData:[[message rawMessageData] dataByAppendingByte:iTetNetworkTerminatorCharacter]
			  withTimeout:-1
					  tag:0];
}

- (void)onSocket:(AsyncSocket*)socket
	 didReadData:(NSData*)data
		 withTag:(long)tag
{
#ifdef _ITETRINET_DEBUG
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableMessageLogging"])
	{
		NSString* messageContents = [NSString stringWithMessageData:[data subdataToIndex:([data length] - 1)]];
		NSMutableString* debugString = [NSMutableString string];
		unichar character;
		for (NSUInteger i = 0; i < [messageContents length]; i++)
		{
			character = [messageContents characterAtIndex:i];
			if ([[iTetTextAttributes chatTextAttributeCharacterSet] characterIsMember:character])
				[debugString appendFormat:@"<\\%02u>", character];
			else
				[debugString appendFormat:@"%C", character];
		}
		NSLog(@"DEBUG:   received incoming message: '%@'", debugString);
	}
#endif
	
	// Convert the data to a message, after trimming the delimiter byte
	iTetMessage* message = [iTetMessage messageWithMessageData:[data subdataToIndex:([data length] - 1)]];
	
	// Hand off the message for processing
	[self messageReceived:message];
	
	// Continue reading data
	[gameSocket readDataToData:[NSData dataWithByte:iTetNetworkTerminatorCharacter]
				   withTimeout:-1
						   tag:0];
}

#define iTetNoConnectingUnspecifiedReasonPlaceHolder	NSLocalizedStringFromTable(@"(No reason given)", @"NetworkController", @"Placeholder for informational text when a server refuses the user's login, but provides no reason with the rejection message")

- (void)messageReceived:(iTetMessage*)message
{
	// Determine the nature of the message
	iTetMessageType type = [message type];
	switch (type)
	{
#pragma mark No Connecting (Error) Message
		case noConnectingMessage:
		{
			// Check if the server provided a reason for rejecting the connection
			NSString* reason = [[message contents] objectForKey:iTetMessageNoConnectingReasonKey];
			NSDictionary* info;
			if ([reason length] > 0)
			{
				info = [NSDictionary dictionaryWithObject:reason
												   forKey:NSLocalizedFailureReasonErrorKey];
			}
			else
			{
				info = [NSDictionary dictionaryWithObject:iTetNoConnectingUnspecifiedReasonPlaceHolder
												   forKey:NSLocalizedFailureReasonErrorKey];
			}
			
			// Create an error
			NSError* error = [NSError errorWithDomain:iTetNetworkErrorDomain
												 code:iTetNoConnectingError
											 userInfo:info];
			
			// Pass the error to our own error-handling method
			[self handleError:error];
			
			break;
		}
#pragma mark Server Heartbeat
		case heartbeatMessage:
		{
			// Send a keepalive message
			[self sendMessage:[iTetMessage messageWithMessageType:heartbeatMessage]];
			
			break;
		}
#pragma mark Client Info Request
		case clientInfoRequestMessage:
		{
			// Send client info to server
			iTetMessage* replyMessage = [iTetMessage messageWithMessageType:clientInfoReplyMessage];
			[[replyMessage contents] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]
										forKey:iTetMessageClientNameKey];
			[[replyMessage contents] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]
										forKey:iTetMessageClientVersionKey];
			[self sendMessage:replyMessage];
			
			break;
		}	
#pragma mark Player Number Message
		case tetrinetPlayerNumberMessage:
		case tetrifastPlayerNumberMessage:
		{
			// Read the player number
			NSInteger playerNumber = [[message contents] integerForKey:iTetMessagePlayerNumberKey];
			
			// Check if we've been assigned a player number yet
			if ([playersController localPlayer] == nil)
			{
				// Create the local player object
				[playersController createLocalPlayerWithNumber:playerNumber
													  nickname:[connectingPlayer nickname]
													  teamName:[connectingPlayer teamName]];
				
				// Treat this as the sign of a successful connection
				[self setConnectionState:connected];
			}
			// Check if we're being moved to a new slot (probably a sign we've moved to a new channel)
			else if (playerNumber != [[playersController localPlayer] playerNumber])
			{
				[playersController changeLocalPlayerNumber:playerNumber];
			}
			
			// Send the local player's team name to the server
			iTetMessage* replyMessage = [iTetMessage messageWithMessageType:playerTeamMessage];
			[[replyMessage contents] setInteger:playerNumber
										 forKey:iTetMessagePlayerNumberKey];
			[[replyMessage contents] setObject:[[playersController localPlayer] teamName]
										forKey:iTetMessagePlayerTeamNameKey];
			[self sendMessage:replyMessage];
			
			// Refresh channel list
			[channelsController refreshChannelList:self];
			
			break;
		}
#pragma mark Player Join Message
		case playerJoinMessage:
		{
			// Check that this isn't an echo of our own join event
			NSString* nickname = [[message contents] objectForKey:iTetMessagePlayerNicknameKey];
			if ([nickname isEqualToString:[[playersController localPlayer] nickname]])
				 break;
			
			// Add a new player with the specified name and number
			[playersController addPlayerWithNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]
										  nickname:nickname];
			
			// Refresh the channel list
			[channelsController refreshChannelList:self];
			
			break;
		}	
#pragma mark Player Leave Message
		case playerLeaveMessage:
		{
			// Get the player number
			NSInteger playerNumber = [[message contents] integerForKey:iTetMessagePlayerNumberKey];
			
			// If this message refers to the local player, ignore
			if (playerNumber == [[playersController localPlayer] playerNumber])
				break;
			
			// Remove the player from the game
			[playersController removePlayerNumber:playerNumber];
			
			// Refresh the channel list
			[channelsController refreshChannelList:self];
			
			break;
		}
#pragma mark Player Kick Message
		case playerKickMessage:
		{
			// Kick the specified player
			[playersController kickPlayerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]];
			
			break;
		}
#pragma mark Player Team Message
		case playerTeamMessage:
		{
			// Change the specified player's team name
			[playersController setTeamName:[[message contents] objectForKey:iTetMessagePlayerTeamNameKey]
						   forPlayerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]];
			
			break;
		}
#pragma mark Winlist Message
		case winlistMessage:
		{
			// Pass the winlist entries to the winlist controller
			[winlistController parseWinlist:[[message contents] objectForKey:iTetMessageWinlistArrayKey]];
			
			break;
		}
#pragma mark Partyline Messages
		case plineChatMessage:
		case plineActionMessage:
		{
			// Add the message to the chat controller
			[chatController appendChatLine:[[message contents] objectForKey:iTetMessageChatContentsKey]
								fromPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]]
									action:(type == plineActionMessage)];
			
			break;
		}
#pragma mark Game Chat Message
		case gameChatMessage:
		{
			// Hand the message to the game controller for processing
			[gameController chatMessageReceived:[[message contents] objectForKey:iTetMessageChatContentsKey]];
			
			break;
		}
#pragma mark New Game Message
		case tetrinetNewGameMessage:
		case tetrifastNewGameMessage:
		{
			// Tell the game controller to start the game
			[gameController newGameWithPlayers:[playersController playerList]
										 rules:[iTetGameRules gameRulesFromArray:[[message contents] objectForKey:iTetMessageGameRulesArrayKey]
																	withGameType:currentServerProtocol
																	 gameVersion:currentGameVersion]];
			
			// Clear the last designated winning player
			[playersController setLastWinningPlayer:nil];
			
			break;
		}
#pragma mark Server In-Game Message
		case inGameMessage:
		{
			// Set all players except the local player to "playing"
			[playersController setGameStartedForAllRemotePlayers];
			
			// Clear the last designated winning player
			[playersController setLastWinningPlayer:nil];
			
			// Give the local player a "death field"
			[[playersController localPlayer] setField:[iTetField fieldWithRandomContents]];
			
			// Set the game view controller's state as "playing"
			[gameController setGameplayState:gamePlaying];
			
			break;
		}
#pragma mark Pause/Resume Game Message
		case pauseResumeGameMessage:
		{
			// Get pause state
			BOOL pauseGame = [[message contents] boolForKey:iTetMessagePauseResumeRequestTypeKey];
			
			// Pause or resume the game
			if (pauseGame && ([gameController gameplayState] == gamePlaying))
			{
				// Pause the game
				[gameController pauseGame];
			}
			else if (!pauseGame && ([gameController gameplayState] == gamePaused))
			{
				// Resume the game
				[gameController resumeGame];
			}
			
			// Refresh the channel list
			[channelsController refreshChannelList:self];
			
			break;
		}
#pragma mark End of Game Message
		case endGameMessage:
		{
			// End the game
			[gameController endGame];
			
			// If the user wants us to, automatically switch to the chat tab
			if ([[NSUserDefaults standardUserDefaults] boolForKey:iTetAutoSwitchChatAfterGamePrefKey])
				[windowController switchToChatTab:self];
			
			// Refresh the channel list
			[channelsController refreshChannelList:self];
			
			break;
		}
#pragma mark Fieldstring Message
		case fieldstringMessage:
		{
			// Pass to the game controller
			[gameController fieldstringReceived:[[message contents] objectForKey:iTetMessageFieldstringKey]
									  forPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]]];
			
			break;
		}
#pragma mark Level Update Message
		case levelUpdateMessage:
		{
			// Check that the level update isn't an echo of one we just sent
			NSInteger playerNumber = [[message contents] integerForKey:iTetMessagePlayerNumberKey];
			if (playerNumber == [[playersController localPlayer] playerNumber])
				break;
			
			// Otherwise, update the specified player's level
			[playersController setLevel:[[message contents] integerForKey:iTetMessageLevelNumberKey]
						forPlayerNumber:playerNumber];
			
			break;
		}
#pragma mark Special Used/Lines Received Message
		case specialUsedMessage:
		{
			// Pass to game controller
			[gameController specialUsed:[[message contents] objectForKey:iTetMessageSpecialKey]
							   byPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]]
							   onPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessageTargetPlayerNumberKey]]];
			
			break;
		}
#pragma mark Player Lost Message
		case playerLostMessage:
		{
			// Set the player to "not playing"
			[playersController setGameLostForPlayerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]];
			
			break;
		}
#pragma mark Player Won Message
		case playerWonMessage:
		{
			// Designate the game's winner
			[playersController setLastWinningPlayer:[playersController playerNumber:[[message contents] integerForKey:iTetMessagePlayerNumberKey]]];
			
			break;
		}
		default:
		{
			NSString* excDesc = [NSString stringWithFormat:@"unknown message type in NetworkController -messageReceived: %d; contents: %@", type, [message contents]];
			NSException* unknownMessageException = [NSException exceptionWithName:@"iTetUnknownMessageTypeException"
																		   reason:excDesc
																		 userInfo:nil];
			@throw unknownMessageException;
		}
	}
}

#pragma mark -
#pragma mark Errors

#define iTetConnectionErrorAlertTitle					NSLocalizedStringFromTable(@"Connection error", @"NetworkController", @"Title of alert displayed when an error occurs while connecting or connected to a server")
#define iTetConnectionRefusedErrorAlertInformativeText	NSLocalizedStringFromTable(@"Connection refused.", @"NetworkController", @"Informative text on alert displayed in the event of a 'connection refused' error when connecting to a server")
#define iTetHostUnreachableErrorAlertInformativeText	NSLocalizedStringFromTable(@"Could not open a connection to the server.", @"NetworkController", @"Informative text on alert displayed in the event of a 'host unreachable' error when connecting to a server")
#define iTetPOSIXNetworkErrorAlertInformativeText		NSLocalizedStringFromTable(@"A connection error occurred:", @"NetworkController", @"Informative text prefixing information displayed on an alert describing a generic connection error")
#define iTetUnknownHostErrorAlertInformativeText		NSLocalizedStringFromTable(@"Could not find the server.", @"NetworkController", @"Informative text on alert displayed in the event that a DNS lookup on a server name returns no results")
#define iTetServerLookupErrorAlertInformativeText		NSLocalizedStringFromTable(@"An error occurred while trying to find the server.", @"NetworkController", @"Informative text on alert displayed when a DNS lookup causes an error, prior to the error code")
#define iTetLocalNetworkErrorAlertInformativeText		NSLocalizedStringFromTable(@"A local network error occurred:", @"NetworkController", @"Informative text prefixing information displayed on an alert describing a local network problem")
#define iTetConnectionTimeoutAlertInformativeText		NSLocalizedStringFromTable(@"The connection timed out.", @"NetworkController", @"Informative text on alert displayed when connecting to a server fails due to timeout")
#define iTetNoConnectingErrorAlertInformativeText		NSLocalizedStringFromTable(@"Server refused login:", @"NetworkController", @"Informative text prefixing a reason received from a server when it won't allow the user to log in")
#define iTetUnknownNetworkErrorAlertInformativeText		NSLocalizedStringFromTable(@"An unknown error occurred:", @"NetworkController", @"Informative text prefixing information about an unknown connection error")

#define iTetCheckServerRecoverySuggestionText			NSLocalizedStringFromTable(@"Check the address of the server you are attempting to connect to and try again.", @"NetworkController", @"After a connection error message, suggestion that the user check that the host address is running a TetriNET server before retrying")
#define iTetCheckNetworkRecoverySuggestionText			NSLocalizedStringFromTable(@"Check that your computer is connected to the internet, or check the server address and try again.", @"NetworkController", @"After a connection error message, suggestion that the user check his or her computer's network state and the server address before retrying")

#define iTetErrorDomainLabelFormat						NSLocalizedStringFromTable(@"Error domain: %@", @"NetworkController", @"Label for the domain of an unknown connection error")
#define iTetErrorCodeLabelFormat						NSLocalizedStringFromTable(@"Error code: %d", @"NetworkController", @"Label for the code of an unknown connection error")

- (void)handleError:(NSError*)error
{
	// Change the connection state
	[self setConnectionState:connectionError];
	
	// Create an alert
	NSAlert* alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:iTetConnectionErrorAlertTitle];
	NSMutableArray* errorTextLines = [NSMutableArray array];
	
	// Determine the type of error
	NSString* errorDomain = [error domain];
	NSInteger errorCode = [error code];
	if ([errorDomain isEqualToString:NSPOSIXErrorDomain])
	{
		switch (errorCode)
		{
			case ECONNREFUSED:
				[errorTextLines addObject:iTetConnectionRefusedErrorAlertInformativeText];
				[errorTextLines addObject:iTetCheckServerRecoverySuggestionText];
				break;
			case EHOSTUNREACH:
				[errorTextLines addObject:iTetHostUnreachableErrorAlertInformativeText];
				[errorTextLines addObject:iTetCheckNetworkRecoverySuggestionText];
				break;
			default:
				[errorTextLines addObject:iTetPOSIXNetworkErrorAlertInformativeText];
				[errorTextLines addObject:[error localizedDescription]];
				break;
		}
	}
	else if ([errorDomain isEqualToString:(NSString*)kCFErrorDomainCFNetwork])
	{
		switch (errorCode)
		{
			case kCFHostErrorUnknown:
			{
				int addrInfoErrorCode = [[[error userInfo] objectForKey:(NSString*)kCFGetAddrInfoFailureKey] intValue];
				switch (addrInfoErrorCode)
				{
					case EAI_NONAME:
						[errorTextLines addObject:iTetUnknownHostErrorAlertInformativeText];
						[errorTextLines addObject:iTetCheckNetworkRecoverySuggestionText];
						break;
					default:
						[errorTextLines addObject:iTetServerLookupErrorAlertInformativeText];
						[errorTextLines addObject:[NSString stringWithFormat:iTetErrorCodeLabelFormat, addrInfoErrorCode]];
						break;
				}
				break;
			}
			default:
				[errorTextLines addObject:iTetLocalNetworkErrorAlertInformativeText];
				[errorTextLines addObject:[error localizedDescription]];
				break;
		}
	}
	else if ([errorDomain isEqualToString:AsyncSocketErrorDomain])
	{
		switch (errorCode)
		{
			case AsyncSocketReadTimeoutError:
				[errorTextLines addObject:iTetConnectionTimeoutAlertInformativeText];
				[errorTextLines addObject:iTetCheckServerRecoverySuggestionText];
				break;
			default:
				[errorTextLines addObject:iTetUnknownNetworkErrorAlertInformativeText];
				[errorTextLines addObject:[NSString stringWithFormat:iTetErrorDomainLabelFormat, errorDomain]];
				[errorTextLines addObject:[NSString stringWithFormat:iTetErrorCodeLabelFormat, errorCode]];
				break;
		}
	}
	else if ([errorDomain isEqualToString:iTetNetworkErrorDomain])
	{
		switch (errorCode)
		{
			case iTetNoConnectingError:
				[errorTextLines addObject:iTetNoConnectingErrorAlertInformativeText];
				[errorTextLines addObject:[error localizedFailureReason]];
				break;
			default:
				[errorTextLines addObject:iTetUnknownNetworkErrorAlertInformativeText];
				[errorTextLines addObject:[NSString stringWithFormat:iTetErrorDomainLabelFormat, errorDomain]];
				[errorTextLines addObject:[NSString stringWithFormat:iTetErrorCodeLabelFormat, errorCode]];
				break;
		}
	}
	else
	{
		[errorTextLines addObject:iTetUnknownNetworkErrorAlertInformativeText];
		[errorTextLines addObject:[NSString stringWithFormat:iTetErrorDomainLabelFormat, errorDomain]];
		[errorTextLines addObject:[NSString stringWithFormat:iTetErrorCodeLabelFormat, errorCode]];
	}
	
	// Compose the lines of the error message into a single string, joined by line separators
	NSString* errorText = [errorTextLines componentsJoinedByString:[NSString stringWithFormat:@"%C", NSLineSeparatorCharacter]];
	
	// Add the error information to the alert, along with an "Okay" button
	[alert setInformativeText:errorText];
	[alert addButtonWithTitle:iTetOKButtonTitle];
	
	// Run the error as a sheet
	[alert beginSheetModalForWindow:[windowController window]
					  modalDelegate:self
					 didEndSelector:@selector(connectionErrorAlertEnded:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)connectionErrorAlertEnded:(NSAlert*)alert
					   returnCode:(NSInteger)returnCode
					  contextInfo:(void*)contextInfo
{
	// Does nothing
}

#pragma mark -
#pragma mark Accessors

@synthesize currentServerAddress;

#define iTetConnectButtonTitle				NSLocalizedStringFromTable(@"Connect", @"NetworkController", @"Title of button or toolbar button used to open a connection to a server")
#define iTetConnectMenuItemTitle			NSLocalizedStringFromTable(@"Connect to Server...", @"NetworkController", @"Title of menu item used to open a connection to a server")
#define iTetDisconnectedStatusMessage		NSLocalizedStringFromTable(@"Connection Closed", @"NetworkController", @"Status message appended to the chat view after successfully disconnecting from a server")
#define iTetDisconnectedStatusLabel			NSLocalizedStringFromTable(@"Disconnected", @"NetworkController", @"Status label displayed at bottom of window after successfully disconnecting from a server")
#define iTetServerDisconnectedStatusLabel	NSLocalizedStringFromTable(@"Server closed connection", @"NetworkController", @"Status label displayed at bottom of window when the server closes the remote end of the connection")

#define iTetCancelConnectionButtonTitle		NSLocalizedStringFromTable(@"Cancel Connection", @"NetworkController", @"Title of toolbar button used to cancel when attempting to open a connection to a server")
#define iTetCancelConnectionMenuItemTitle	NSLocalizedStringFromTable(@"Cancel Connection in Progress", @"NetworkController", @"Title of menu item used to cancel when attempting to open a connection to a server")
#define iTetConnectingStatusLabelFormat		NSLocalizedStringFromTable(@"Connecting to server %@...", @"NetworkController", @"Status label displayed at bottom of window when a new connection is being opened to a server")

#define iTetConnectionOpenedStatusMessage	NSLocalizedStringFromTable(@"Connection Opened", @"NetworkController", @"Status message appended to the chat view after successfully opening a connection to a server")
#define iTetLoggingInStatusLabelFormat		NSLocalizedStringFromTable(@"Logging in as %@...", @"NetworkController", @"Status label displayed at bottom of window while logging in to a server")

#define iTetConnectionCanceledStatusLabel	NSLocalizedStringFromTable(@"Connection canceled", @"NetworkController", @"Status label displayed at the bottom of the window after cancelling a connection to a server")

#define iTetDisconnectButtonTitle			NSLocalizedStringFromTable(@"Disconnect", @"NetworkController", @"Title of button or toolbar button used to close an open connection to a server")
#define iTetDisconnectMenuItemTitle			NSLocalizedStringFromTable(@"Disconect from Server", @"NetworkController", @"Title of menu item used to close an open connection to a server")
#define iTetConnectedStatusLabel			NSLocalizedStringFromTable(@"Connected", @"NetworkController", @"Status label displayed at bottom of window while connected to a server")

#define iTetDisconnectingStatusLabel		NSLocalizedStringFromTable(@"Disconnecting...", @"NetworkController", @"Status label displayed at bottom of window while disconnecting from a server")

#define iTetConnectionErrorStatusMessage	NSLocalizedStringFromTable(@"Connection Error", @"NetworkController", @"Status message appended to the chat view if a connection error occurs")
#define iTetConnectionErrorStatusLabel		NSLocalizedStringFromTable(@"Connection error occurred", @"NetworkController", @"Status label displayed at bottom of window if a connection error occurs")

- (void)setConnectionState:(iTetConnectionState)newState
{
	if (connectionState == newState)
		return;
	
	switch (newState)
	{
		case disconnected:
			// Reset the connection toolbar item
			[connectionButton setLabel:iTetConnectButtonTitle];
			[connectionButton setImage:[NSImage imageNamed:@"Network"]];
			
			// Reset the connection menu item
			[connectionMenuItem setTitle:iTetConnectMenuItemTitle];
			[connectionMenuItem setKeyEquivalent:@"o"];
			
			// If the connection was not canceled or errored-out, this was a "clean" disconnect
			if ((connectionState != connectionError) && (connectionState != canceled))
			{
				// Append a status message to the chat tab
				[chatController appendStatusMessage:iTetDisconnectedStatusMessage];
				
				// Change the connection status label
				if (connectionState != disconnecting)
				{
					// If the connection closed unexpectedly, blame the server
					[connectionStatusLabel setStringValue:iTetServerDisconnectedStatusLabel];
					
					// Make sure the progress indicator is stopped
					[connectionProgressIndicator stopAnimation:self];
				}
				else
				{
					[connectionStatusLabel setStringValue:iTetDisconnectedStatusLabel];
				}
			}
			
			break;
			
		case connecting:
			// Change the connection toolbar and menu items to "abort" actions
			[connectionButton setLabel:iTetCancelConnectionButtonTitle];
			[connectionButton setImage:[NSImage imageNamed:@"Cancel Red Button"]];
			[connectionMenuItem setTitle:iTetCancelConnectionMenuItemTitle];
			[connectionMenuItem setKeyEquivalent:@"d"];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:[NSString stringWithFormat:iTetConnectingStatusLabelFormat, currentServerAddress]];
			
			// Start the progress indicator
			[connectionProgressIndicator startAnimation:self];
			
			break;
			
		case login:
			// Clear the chat views, and append a status message on the chat tab
			[chatController clearChat];
			[gameController clearChat];
			[chatController appendStatusMessage:iTetConnectionOpenedStatusMessage];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:[NSString stringWithFormat:iTetLoggingInStatusLabelFormat, [connectingPlayer nickname]]];
			
			break;
			
		case canceled:
			// Stop the progress indicator
			[connectionProgressIndicator stopAnimation:self];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:iTetConnectionCanceledStatusLabel];
			
			// If we had already opened the connection, append a status message indicating we are closing it
			if (connectionState == login)
				[chatController appendStatusMessage:iTetDisconnectedStatusMessage];
			
			break;
			
		case connected:
			// Stop the progress indicator
			[connectionProgressIndicator stopAnimation:self];
			
			// Change the connection toolbar and menu items to "disconnect" actions
			[connectionButton setLabel:iTetDisconnectButtonTitle];
			[connectionButton setImage:[NSImage imageNamed:@"Eject Blue Button"]];
			[connectionMenuItem setTitle:iTetDisconnectMenuItemTitle];
			[connectionMenuItem setKeyEquivalent:@"d"];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:iTetConnectedStatusLabel];
			
			// Attempt to retrieve the server's channel list
			[channelsController requestChannelListFromServer:currentServerAddress];
			
			// If the user wants us to, automatically switch to the chat tab
			if ([[NSUserDefaults standardUserDefaults] boolForKey:iTetAutoSwitchChatOnConnectPrefKey])
				[windowController switchToChatTab:self];
			
			break;
			
		case disconnecting:
			// Change the connection status label
			[connectionStatusLabel setStringValue:iTetDisconnectingStatusLabel];
			
			break;
			
		case connectionError:
			// If we were connecting, stop the progress indicator
			if ((connectionState == connecting) || (connectionState == login))
				[connectionProgressIndicator stopAnimation:self];
			
			// If the connection was open when the error occurred, append a status message
			if ((connectionState == connected) || (connectionState == login))
				[chatController appendStatusMessage:iTetConnectionErrorStatusMessage];
			
			// Change the connection status label
			[connectionStatusLabel setStringValue:iTetConnectionErrorStatusLabel];
			
			break;
	}
	
	connectionState = newState;
}
@synthesize connectionState;

- (BOOL)connectionOpen
{
	return ([self connectionState] == connected);
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
	NSSet* keys = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"connectionOpen"])
		keys = [keys setByAddingObject:@"connectionState"];
	
	return keys;
}

@end
