//
//  iTetThemesSupportDirectory.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/21/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface iTetThemesSupportDirectory : NSObject

// Returns the path to a named subdirectory of the app's Application Support/Themes/ directory, creating it if it doesn't exist and 'create' is YES; returns nil if an error occurs, or the directory does not exist and was not created
+ (NSString*)pathToSupportDirectoryForTheme:(NSString*)themeName
						  createIfNecessary:(BOOL)create
									  error:(NSError**)error;

@end
