//
//  iTetGameContext.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/16/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@class iTetGame;

/*!
 An abstract class representing the context in which a game of TetriNET is played; i.e., containing the channels, players, chat, etc., pertaining to the game, including the game object itself.
 */
@interface iTetGameContext : NSObject
{
	iTetGame* game;	/*!< The current game in progress in this context, if any. */
}

@property (readonly) BOOL isOfflineContext;	/*!< Abstract property; subclasses must override. If \c YES, this context is not associated with a network connection. */
@property (readonly) iTetGame* game;
@property (readonly) BOOL gameInProgress;	/*!< Convenience accessor; returns \c YES if there is a game in progress in this context, i.e., if \c game is non-nil. */

@end
