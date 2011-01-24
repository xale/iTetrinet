//
//  IPSApplicationSupportDirectory.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/20/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface IPSApplicationSupportDirectory : NSObject

// Returns the full path to the appropriate Application Support subdirectory for the specified application, (creating it if necessary) or nil if an error occurs
+ (NSString*)pathToSupportDirectoryForApplication:(NSString*)appName
											error:(NSError**)error;

@end
