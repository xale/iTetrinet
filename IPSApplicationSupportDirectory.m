//
//  IPSApplicationSupportDirectory.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/20/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "IPSApplicationSupportDirectory.h"

NSFileManager* supportFileManager = nil;

@interface IPSApplicationSupportDirectory (Private)

+ (NSString*)userApplicationSupportDirectoryPath;

@end

@implementation IPSApplicationSupportDirectory

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

#pragma mark -
#pragma mark Path Utilities

NSString* const IPSCompanyApplicationSupportSubdirectoryName = @"Indie Pennant";

#define IPSSupportDirectoryCreationErrorDescription	NSLocalizedStringFromTable(@"Unable to create Application Support subdirectory", @"IPSApplicationSupportDirectory", @"Simple error description displayed when the application is unable to create a named subdirectory of the user's ~/Library/Application Support/ directory; the underlying cause of the error is specified elsewhere")

+ (NSString*)applicationSupportDirectoryPathForApp:(NSString*)appName
											 error:(NSError**)error
{
	// Attempt to find the user's "Application Support" directory
	NSString* supportPath = [self userApplicationSupportDirectoryPath];
	
	// If (for some bizarre reason) we can't find it, bail
	if (supportPath == nil)
	{
		// If an error pointer has been provided, create an error
		if (error != NULL)
		{
			*error = [NSError errorWithDomain:NSCocoaErrorDomain
										 code:NSFileNoSuchFileError
									 userInfo:nil];
		}
		
		return nil;
	}
	
	// Create the full path to the app's support directory
	NSString* fullPath = [supportPath stringByAppendingPathComponent:IPSCompanyApplicationSupportSubdirectoryName];
	fullPath = [fullPath stringByAppendingPathComponent:appName];
	
	// Check if the path already exists
	NSFileManager* fileManager = [[[NSFileManager alloc] init] autorelease];
	if ([fileManager fileExistsAtPath:fullPath])
		return fullPath;
	
	// Attempt to create the directory
	NSError* creationError;
	BOOL createdSuccessfully = [fileManager createDirectoryAtPath:fullPath
									  withIntermediateDirectories:YES
													   attributes:nil
															error:&creationError];
	
	// If the directory could not be created, return nil
	if (!createdSuccessfully)
	{
		// If an error pointer was provided, create an error
		if (error != NULL)
		{
			// Create a user info dictionary
			NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  IPSSupportDirectoryCreationErrorDescription, NSLocalizedDescriptionKey,
									  creationError, NSUnderlyingErrorKey,
									  fullPath, NSFilePathErrorKey,
									  nil];
			
			// Create the error
			*error = [NSError errorWithDomain:NSCocoaErrorDomain
										 code:NSFileNoSuchFileError
									 userInfo:userInfo];
		}
		
		return nil;
	}
	
	// Return the path to the created directory
	return fullPath;
}

+ (NSString*)userApplicationSupportDirectoryPath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	
	if ([paths count] == 0)
		return nil;
	
	return [paths objectAtIndex:0];
}

@end
