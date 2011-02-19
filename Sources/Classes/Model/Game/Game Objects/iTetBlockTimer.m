//
//  iTetBlockTimer.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/17/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetBlockTimer.h"

@implementation iTetBlockTimer

#define ITET_TETRINET_BLOCK_DELAY		1.0

+ (id)nextBlockTimerWithTarget:(id)target
					  selector:(SEL)selector
			scheduledInRunLoop:(NSRunLoop*)runLoop
{
	return [[[self alloc] initWithDelay:ITET_TETRINET_BLOCK_DELAY
								 target:target
							   selector:selector
					 scheduledInRunLoop:runLoop
								repeats:NO] autorelease];
}

NSTimeInterval blockFallDelayForLevel(NSInteger level);

+ (id)blockFallTimerForLevel:(NSInteger)level
				  withTarget:(id)target
					selector:(SEL)selector
		  scheduledInRunLoop:(NSRunLoop*)runLoop
{
	return [[[self alloc] initWithDelay:blockFallDelayForLevel(level)
								 target:target
							   selector:selector
					 scheduledInRunLoop:runLoop
								repeats:YES] autorelease];
}

- (id)initWithDelay:(NSTimeInterval)delay
			 target:(id)target
		   selector:(SEL)selector
 scheduledInRunLoop:(NSRunLoop*)runLoop
			repeats:(BOOL)repeats
{
	// Create and start the timer
	timer = [NSTimer timerWithTimeInterval:delay
									target:target
								  selector:selector
								  userInfo:nil
								   repeats:repeats];
	[runLoop addTimer:timer
			  forMode:NSRunLoopCommonModes];
	
	// Record any information about the timer that will be needed to resume the timer after pausing
	timerDelay = delay;
	timerTarget = target;
	timerSelector = selector;
	timerRunLoop = runLoop;
	timerRepeats = repeats;
	
	return self;
}

- (void)dealloc
{
	[timer invalidate];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (void)setPaused:(BOOL)pauseTimer
{
	// Determine if the timer should be paused or unpaused
	// Pause
	if (!paused && pauseTimer)
	{
		// Record when the timer will next fire
		timeUntilNextFire = [[timer fireDate] timeIntervalSinceNow];
		
		// Invalidate and nil the timer
		[timer invalidate];
		timer = nil;
		
		paused = YES;
	}
	// Unpause
	else if (paused && !pauseTimer)
	{
		// Re-create the timer
		timer = [[[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeUntilNextFire]
										  interval:timerDelay
											target:timerTarget
										  selector:timerSelector
										  userInfo:nil
										   repeats:timerRepeats] autorelease];
		
		// Attach the timer to the run loop
		[timerRunLoop addTimer:timer
					   forMode:NSRunLoopCommonModes];
		
		paused = NO;
	}
}
@synthesize paused;

@end

#define ITET_MAX_DELAY_TIME				(1.005)
#define ITET_DELAY_REDUCTION_PER_LEVEL	(0.01)
#define ITET_MIN_DELAY_TIME				(0.005)

NSTimeInterval blockFallDelayForLevel(NSInteger level)
{
	NSTimeInterval time = ITET_MAX_DELAY_TIME - (level * ITET_DELAY_REDUCTION_PER_LEVEL);
	
	if (time < ITET_MIN_DELAY_TIME)
		return ITET_MIN_DELAY_TIME;
	
	return time;
}
