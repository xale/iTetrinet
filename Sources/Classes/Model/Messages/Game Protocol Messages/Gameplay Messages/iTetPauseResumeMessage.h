//
//  iTetPauseResumeMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetMessage.h"
#import "iTetGameplayState.h"

extern NSString* const iTetPauseResumeMessageTag;

@interface iTetPauseResumeMessage : iTetMessage
{
	iTetPauseResumeState pauseState;	/*!< Whether or not the game is (or should be) paused. */
}

+ (id)messageWithPauseState:(iTetPauseResumeState)state;
- (id)initWithPauseState:(iTetPauseResumeState)state;

@property (readonly) iTetPauseResumeState pauseState;

@end
