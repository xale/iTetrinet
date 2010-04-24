//
//  IPSApplicationSupportDirectory.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/20/10.
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
	NSFileManager* fileManager = [[NSFileManager alloc] init];
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
									  @"Unable to create Application Support directory", NSLocalizedDescriptionKey,
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
