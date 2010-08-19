//
//  iTetGrowlController.h
//  iTetrinet
//
//  Created by Alex Heinz on 8/18/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface iTetGrowlController : NSObject <GrowlApplicationBridgeDelegate>

+ (iTetGrowlController*)sharedGrowlController;

- (void)postGrowlNotificationWithTitle:(NSString*)title
						   description:(NSString*)description
					  notificationName:(NSString*)name;

@end
