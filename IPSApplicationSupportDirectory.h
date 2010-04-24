//
//  IPSApplicationSupportDirectory.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/20/10.
//

#import <Cocoa/Cocoa.h>

@interface IPSApplicationSupportDirectory : NSObject

// Returns the full path to the appropriate Application Support subdirectory for the specified application, (creating it if necessary) or nil if an error occurs
+ (NSString*)applicationSupportDirectoryPathForApp:(NSString*)appName
											 error:(NSError**)error;

@end
