//
//  iTetBlockTimer.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/17/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface iTetBlockTimer : NSObject
{
	// Wrapped timer
	NSTimer* timer;
	NSTimeInterval timerDelay;
	id timerTarget;
	SEL timerSelector;
	NSRunLoop* timerRunLoop;
	BOOL timerRepeats;
	
	// Pause state
	BOOL paused;
	NSTimeInterval timeUntilNextFire;
}

+ (id)nextBlockTimerWithTarget:(id)target
					  selector:(SEL)selector
			scheduledInRunLoop:(NSRunLoop*)runLoop;
+ (id)blockFallTimerForLevel:(NSInteger)level
				  withTarget:(id)target
					selector:(SEL)selector
		  scheduledInRunLoop:(NSRunLoop*)runLoop;
- (id)initWithDelay:(NSTimeInterval)delay
			 target:(id)target
		   selector:(SEL)selector
 scheduledInRunLoop:(NSRunLoop*)runLoop
			repeats:(BOOL)repeats;

@property (nonatomic, readwrite, assign, getter=isPaused) BOOL paused;

@end
