//
//  iTetThemesSupportDirectory.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/21/10.
//

#import <Cocoa/Cocoa.h>

@interface iTetThemesSupportDirectory : NSObject

// Returns the path to a named subdirectory of the app's Application Support/Themes/ directory, creating it if necessary, or nil if an error occurs
+ (NSString*)pathToSupportDirectoryForTheme:(NSString*)themeName
									  error:(NSError**)error;

@end
