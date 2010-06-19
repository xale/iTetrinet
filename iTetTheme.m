//
//  iTetTheme.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetTheme.h"
#import "iTetThemesSupportDirectory.h"

#import "iTetField.h"
#import "iTetBlock.h"
#import "iTetSpecials.h"

#import "iTetUserDefaults.h"
#import "NSUserDefaults+AdditionalTypes.h"

#import "NSMutableDictionary+CacheDictionary.h"

NSMutableDictionary* themeCache = nil;
NSArray* defaultThemes = nil;

@interface iTetTheme (Private)

- (BOOL)parseThemeFile;
- (NSRange)rangeOfSection:(NSString*)sectionName
			  inThemeFile:(NSString*)themeFileContents;
- (void)loadImages;
- (void)createPreview;

+ (NSMutableDictionary*)themeCache;

@end

@implementation iTetTheme

+ (void)initialize
{
	if (self == [iTetTheme class])
	{
		NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[iTetTheme defaultThemes]]
					 forKey:iTetThemesListPrefKey];
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSIndexSet indexSetWithIndex:0]]
					 forKey:iTetThemesSelectionPrefKey];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	}
}

+ (iTetTheme*)currentTheme
{
	NSArray* themes = [[NSUserDefaults standardUserDefaults] unarchivedObjectForKey:iTetThemesListPrefKey];
	NSIndexSet* themeSelection = [[NSUserDefaults standardUserDefaults] unarchivedObjectForKey:iTetThemesSelectionPrefKey];
	
	if (([themeSelection count] == 0) || ([themes objectAtIndex:[themeSelection firstIndex]] == [NSNull null]))
		return [self defaultTheme];
	
	return [themes objectAtIndex:[themeSelection firstIndex]];
}

+ (NSArray*)defaultThemes
{
	@synchronized(self)
	{
		if (defaultThemes == nil)
		{
			defaultThemes = [[NSArray alloc] initWithObjects:
							 [self themeFromThemeFile:[[NSBundle mainBundle] pathForResource:@"theme"
																					  ofType:@"cfg"]],
							 [self themeFromThemeFile:[[NSBundle mainBundle] pathForResource:@"theme_white"
																					  ofType:@"cfg"]],
							 [self themeFromThemeFile:[[NSBundle mainBundle] pathForResource:@"theme_mono"
																					  ofType:@"cfg"]],
							 [self themeFromThemeFile:[[NSBundle mainBundle] pathForResource:@"GTetrinetTheme"
																					  ofType:@"cfg"]],
							 nil];
			
			for (iTetTheme* theme in defaultThemes)
			{
				[[iTetTheme themeCache] setObject:theme
										   forKey:[theme themeFilePath]];
			}
		}
	}
	
	return defaultThemes;
}

+ (id)defaultTheme
{
	return [[self defaultThemes] objectAtIndex:0];
}

+ (id)themeFromThemeFile:(NSString*)path
{
	return [[[self alloc] initWithThemeFile:path] autorelease];
}

- (id)initWithThemeFile:(NSString*)path
{
	// Copy theme file path
	themeFilePath = [path copy];
	
	// Attempt to read data from the theme file
	if (![self parseThemeFile])
	{
		[self release];
		return [NSNull null];
	}
	
	// Load and clip the images from the sheet
	[self loadImages];
	
	// Create the preview image
	[self createPreview];
	
	return self;
}

- (id)init
{	
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

- (void)dealloc
{
	[themeFilePath release];
	[imageFilePath release];
	
	[themeName release];
	[themeAuthor release];
	[themeDescription release];
	
	[background release];
	[cellImages release];
	[specialImages release];
	[preview release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization

#define iTetUnnamedThemePlaceholderName			NSLocalizedStringFromTable(@"Unnamed Theme", @"Themes", @"Placeholder name for themes loaded from a file that does not specify a name for the theme")
#define iTetUnknownThemeAuthorPlaceholderName	NSLocalizedStringFromTable(@"Unknown", @"Themes", @"Placeholder for a theme loaded from a file that does not specify the theme's author")
#define iTetBlankThemeDescriptionPlaceholder	NSLocalizedStringFromTable(@"No description provided.", @"Themes", @"Placeholder for a theme loaded from a file that does not provide a description of the theme")

- (BOOL)parseThemeFile
{
	// Attempt to read the contents of the file
	NSString* themeFile = [NSString stringWithContentsOfFile:themeFilePath
												usedEncoding:nil
													   error:NULL];
	
	// Check that the file was read successfully
	if (themeFile == nil)
		return NO;
	
	// Search for the name of the theme's image
	NSRange dataRange = [self rangeOfSection:@"blocks="
								 inThemeFile:themeFile];
	if (dataRange.location == NSNotFound)
		return NO;
	
	// Create the image path
	NSString* imageName = [themeFile substringWithRange:dataRange];
	imageFilePath = [[themeFilePath stringByDeletingLastPathComponent]
					 stringByAppendingPathComponent:imageName];
	
	// Check that the image path is valid
	if (![[NSFileManager defaultManager] fileExistsAtPath:imageFilePath])
		return NO;
	
	[imageFilePath retain];
	
	// Search for the other data in the theme file
	// Cell size
	dataRange = [self rangeOfSection:@"blocksize="
						 inThemeFile:themeFile];
	if (dataRange.location != NSNotFound)
	{
		CGFloat cell = [[themeFile substringWithRange:dataRange] floatValue];
		cellSize = NSMakeSize(cell, cell);
	}
	else
	{
		cellSize = NSMakeSize(ITET_DEF_CELL_WIDTH, ITET_DEF_CELL_HEIGHT);
	}
	
	// Name
	dataRange = [self rangeOfSection:@"name="
						 inThemeFile:themeFile];
	if (dataRange.location != NSNotFound)
		themeName = [[themeFile substringWithRange:dataRange] retain];
	else
		themeName = [[NSString alloc] initWithString:iTetUnnamedThemePlaceholderName];
	
	// Author
	dataRange = [self rangeOfSection:@"author="
						 inThemeFile:themeFile];
	if (dataRange.location != NSNotFound)
		themeAuthor = [[themeFile substringWithRange:dataRange] retain];
	else
		themeAuthor = [[NSString alloc] initWithString:iTetUnknownThemeAuthorPlaceholderName];
	
	// Description
	dataRange = [self rangeOfSection:@"description="
						 inThemeFile:themeFile];
	if (dataRange.location != NSNotFound)
		themeDescription = [[themeFile substringWithRange:dataRange] retain];
	else
		themeDescription = [[NSString alloc] initWithString:iTetBlankThemeDescriptionPlaceholder];
	
	return YES;
}

- (NSRange)rangeOfSection:(NSString*)sectionName
			  inThemeFile:(NSString*)themeFile
{
	// Locate the section heading
	NSRange searchResult;
	searchResult = [themeFile rangeOfString:sectionName
									options:NSCaseInsensitiveSearch];
	
	// If not found, return "not found"
	if (searchResult.location == NSNotFound)
		return searchResult;
	
	// If the section was found, find the next newline after the section
	NSRange dataRange;
	dataRange.location = NSMaxRange(searchResult);
	dataRange.length = [themeFile length] - dataRange.location;
	searchResult = [themeFile rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
											  options:0
												range:dataRange];
	
	// If a newline was found, the section ends there; otherwise, the section is assumed to end at the end of the file
	if (searchResult.location != NSNotFound)
		dataRange.length = searchResult.location - dataRange.location;
	
	// Check that the length of the section is positive
	if (dataRange.length <= 0)
		return NSMakeRange(NSNotFound, 0);
	
	// Return the range of the section
	return dataRange;
}

- (void)loadImages
{
	NSImage* sheet = [[[NSImage alloc] initWithContentsOfFile:[self imageFilePath]] autorelease];
	
	// Create an image for the background
	NSSize fieldSize = NSMakeSize((cellSize.width * ITET_FIELD_WIDTH),
								  (cellSize.height * ITET_FIELD_HEIGHT));
	background = [[NSImage alloc] initWithSize:fieldSize];
	
	// Draw the background portion of the sheet to the background
	NSRect fieldRect;
	fieldRect.origin = NSZeroPoint;
	fieldRect.size = fieldSize;
	[background lockFocus];
	[sheet drawInRect:fieldRect
			 fromRect:fieldRect
			operation:NSCompositeCopy
			 fraction:1.0];
	[background unlockFocus];
	
	// Create a mutable array to add the cell images to
	NSMutableArray* cells = [NSMutableArray arrayWithCapacity:
							 (ITET_NUM_CELL_COLORS + ITET_NUM_SPECIAL_TYPES)];
	
	// Clip each cell and special image out of the sheet
	NSRect cellRect;
	cellRect.size = cellSize;
	cellRect.origin.y = ([sheet size].height - cellSize.height);
	NSInteger cellNum;
	NSImage* cellImage;
	for (cellNum = 0; cellNum < (ITET_NUM_CELL_COLORS + ITET_NUM_SPECIAL_TYPES); cellNum++)
	{
		cellRect.origin.x = (cellNum * cellRect.size.width);
		
		// Create a new cell image
		cellImage = [[[NSImage alloc] initWithSize:cellSize] autorelease];
		
		// Draw the relevant section of the sheet to the image
		[cellImage lockFocus];
		[sheet drawInRect:NSMakeRect(0, 0, cellSize.width, cellSize.height)
				 fromRect:cellRect
				operation:NSCompositeCopy
				 fraction:1.0];
		[cellImage unlockFocus];
		
		// Add the image to the array of cell images
		[cells addObject:cellImage];
	}
	
	// Fill the cell and special arrays with the images clipped from the sheet
	cellImages = [[NSArray alloc] initWithArray:[cells subarrayWithRange:NSMakeRange(0, ITET_NUM_CELL_COLORS)]];
	specialImages = [[NSArray alloc] initWithArray:[cells subarrayWithRange:NSMakeRange(ITET_NUM_CELL_COLORS, ITET_NUM_SPECIAL_TYPES)]];
}

#define PREVIEW_HEIGHT (225)

- (void)createPreview
{
	// Determine the size of the background when scaled to fit the preview
	CGFloat bgRatio = ([background size].width / [background size].height);
	NSSize bgSize;
	bgSize.height = 225;
	bgSize.width = (bgSize.height * bgRatio);
	
	// Determine the full size of the preview
	NSSize previewSize;
	previewSize.height = bgSize.height;
	previewSize.width = (ITET_DEF_CELL_WIDTH * 2) + bgSize.width;
	
	// Release the old preview image (if it exists)
	[preview release];
	
	// Create a new preview image
	preview = [[NSImage alloc] initWithSize:previewSize];
	[preview lockFocus];
	
	// Draw the cell images
	NSRect targetRect;
	targetRect.size = NSMakeSize(ITET_DEF_CELL_WIDTH, ITET_DEF_CELL_HEIGHT);
	targetRect.origin.x = 0;
	NSInteger cellNum;
	for (cellNum = 0; cellNum < ITET_NUM_CELL_COLORS; cellNum++)
	{
		targetRect.origin.y = previewSize.height - ((cellNum + 1) * ITET_DEF_CELL_HEIGHT);
		
		[[cellImages objectAtIndex:cellNum] drawInRect:targetRect
											  fromRect:NSZeroRect
											 operation:NSCompositeCopy
											  fraction:1.0];
	}
	
	// Draw the specials
	targetRect.origin.x = ITET_DEF_CELL_WIDTH;
	for (cellNum = 0; cellNum < ITET_NUM_SPECIAL_TYPES; cellNum++)
	{
		targetRect.origin.y = previewSize.height - ((cellNum + 1) * ITET_DEF_CELL_HEIGHT);
		
		[[specialImages objectAtIndex:cellNum] drawInRect:targetRect
												 fromRect:NSZeroRect
												operation:NSCompositeCopy
												 fraction:1.0];
	}
	
	// Draw the background (scaled to fit)
	targetRect.size = bgSize;
	targetRect.origin = NSMakePoint((ITET_DEF_CELL_WIDTH * 2), 0);
	[background drawInRect:targetRect
				  fromRect:NSZeroRect
				 operation:NSCompositeCopy
				  fraction:1.0];
	
	[preview unlockFocus];
}

#pragma mark -
#pragma mark Encoding/Decoding

NSString* const iTetThemeFilePathKey = @"themeFilePath";

- (void)encodeWithCoder:(NSCoder*)encoder
{
	// Encode theme file path
	[encoder encodeObject:[self themeFilePath]
				   forKey:iTetThemeFilePathKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	// Load the path to the theme file
	NSString* path = [decoder decodeObjectForKey:iTetThemeFilePathKey];
	
	// Check if this theme is cached
	iTetTheme* cachedTheme = [[iTetTheme themeCache] objectForKey:path];
	if (cachedTheme != nil)
	{
		[self release];
		return [cachedTheme retain];
	}
	
	// Attempt to create the theme from the file at the encoded path
	return [self initWithThemeFile:path];
}

#pragma mark -
#pragma mark File Organization

- (void)copyFiles
{
	// Get the path to a subdirectory of the Application Support directory to store this theme
	NSError* error = nil;
	NSString* directoryPath = [iTetThemesSupportDirectory pathToSupportDirectoryForTheme:[self themeName]
																	   createIfNecessary:YES
																				   error:&error];
	
	// Check for errors
	if (directoryPath == nil)
		goto abort;
	
	// Append the theme and image filenames to the directory path
	NSString* themeDestPath = [directoryPath stringByAppendingPathComponent:[[self themeFilePath] lastPathComponent]];
	NSString* imageDestPath = [directoryPath stringByAppendingPathComponent:[[self imageFilePath] lastPathComponent]];
	
	// Copy the theme file to the support directory
	NSFileManager* fileManager = [[NSFileManager alloc] init];
	[fileManager setDelegate:self];
	BOOL copySuccessful = [fileManager copyItemAtPath:[self themeFilePath]
											   toPath:themeDestPath
												error:&error];
	if (!copySuccessful)
		goto abort;
	
	// Copy the image file
	copySuccessful = [fileManager copyItemAtPath:[self imageFilePath]
										  toPath:imageDestPath
										   error:&error];
	if (!copySuccessful)
		goto abort;
	
	// Update the theme and image file paths to reflect the copied files
	[self willChangeValueForKey:@"themeFilePath"];
	[themeFilePath release];
	themeFilePath = [themeDestPath retain];
	[self didChangeValueForKey:@"themeFilePath"];
	[self willChangeValueForKey:@"imageFilePath"];
	[imageFilePath release];
	imageFilePath = [imageDestPath retain];
	[self didChangeValueForKey:@"imageFilePath"];
	
	// Add theme to cache
	[[iTetTheme themeCache] setObject:self
							   forKey:[self themeFilePath]];
	
abort:
	if (error != nil)
	{
		NSLog(@"WARNING: unable to copy theme files for theme '%@': %@", [self themeName], [error description]);
	}
}

- (void)deleteFiles
{
	// Locate the theme's subdirectory of this user's Application Support directory
	NSString* directoryPath = [iTetThemesSupportDirectory pathToSupportDirectoryForTheme:[self themeName]
																	   createIfNecessary:NO
																				   error:NULL];
	if (directoryPath == nil)
		return;
	
	// Attempt to delete the directory and its contents
	NSFileManager* fileManager = [[[NSFileManager alloc] init] autorelease];
	NSError* error;
	BOOL deleteSuccessful = [fileManager removeItemAtPath:directoryPath
													error:&error];
	if (!deleteSuccessful)
	{
		NSLog(@"WARNING: attempt to delete theme files for theme '%@' was unsuccessful: %@", [self themeName], [error description]);
	}
	
	// Remove theme from cache
	[[iTetTheme themeCache] removeObjectForKey:[self themeFilePath]];
}

- (BOOL)fileManager:(NSFileManager*)fileManager
shouldProceedAfterError:(NSError*)error
  copyingItemAtPath:(NSString*)srcPath
			 toPath:(NSString*)dstPath
{
	// Proceed with copying if the file exists, otherwise abort
	if (([error domain] == NSPOSIXErrorDomain) && ([error code] == EEXIST))
		return YES;
	
	return NO;
}

#pragma mark -
#pragma mark Theme Cache

+ (NSMutableDictionary*)themeCache
{
	@synchronized(self)
	{
		if (themeCache == nil)
		{
			themeCache = [NSMutableDictionary cacheDictionary];
		}
	}
	
	return themeCache;
}

#pragma mark -
#pragma mark Comparators (uses name)

- (BOOL)isEqual:(id)other
{
	if ([other isMemberOfClass:[self class]])
	{
		iTetTheme* otherTheme = (iTetTheme*)other;
		
		if ([[otherTheme themeName] isEqualToString:[self themeName]])
			return YES;
	}
	
	return NO;
}

- (NSUInteger)hash
{
	return [themeName hash];
}

#pragma mark -
#pragma mark Accessors

@synthesize themeFilePath;
@synthesize imageFilePath;

@synthesize themeName;
@synthesize themeAuthor;
@synthesize themeDescription;

@synthesize background;
@synthesize cellSize;
- (NSImage*)imageForCellType:(uint8_t)cellType
{
	// Check if the requested cell is a normal cell or a special
	// If the cell is a normal cell, return one of the normal cell images
	if ((cellType > 0) && (cellType <= ITET_NUM_CELL_COLORS))
	{
		return [cellImages objectAtIndex:(cellType - 1)];
	}
	
	// If the cell is a special, return the image for that special type
	uint8_t num = [iTetSpecials numberForSpecialType:(iTetSpecialType)cellType];
	if (num > 0)
		return [specialImages objectAtIndex:(num - 1)];
	
	// Invalid cell type
	NSLog(@"Warning: Image requested for invalid cell type: %d", cellType);
	return nil;
}

@synthesize preview;

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@: %@", [super description], themeName];
}

@end
