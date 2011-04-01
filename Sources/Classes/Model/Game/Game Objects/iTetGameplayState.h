//
//  iTetGameplayState.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/8/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

typedef enum
{
	gameNotPlaying =	1,
	gamePlaying =		2,
	gamePaused =		3
} iTetGameplayState;

typedef enum
{
	playerNotPlaying =	0,
	playerPlaying =		1,
	playerLost =		2
} iTetPlayerGameplayState;

typedef enum
{
	startGame =	1,
	stopGame =	0
} iTetStartStopState;

typedef enum
{
	pauseGame =		1,
	resumeGame =	0
} iTetPauseResumeState;
