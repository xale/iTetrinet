//
//  iTetTheme.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//  Copyright (c) 2009-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetTheme.h"
#import "iTetThemesSupportDirectory.h"

#import "iTetField.h"
#import "iTetBlock.h"
#import "iTetSpecial.h"

#import "iTetUserDefaults.h"
#import "NSUserDefaults+AdditionalTypes.h"

#import "NSMutableDictionary+CacheDictionary.h"

NSMutableDictionary* themeCache = nil;
NSArray* defaultThemes = nil;

@interface iTetTheme (Private)

- (BOOL)parseThemeFile;
- (NSString*)sectionOfThemeFile:(NSString*)themeFile
				 withIdentifier:(NSString*)sectionName;
- (void)loadImages;
- (NSArray*)cellImagesClippedFromSheet:(NSImage*)sheet
					 beginningWithRect:(NSRect)srcRect;
- (void)createPreview;

- (void)setThemeFilePath:(NSString*)themePath;
- (void)setImageFilePath:(NSString*)imagePath;

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
		return [[NSNull null] retain];
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
	
	[localFieldBackground release];
	[remoteFieldBackground release];
	[localCellImages release];
	[localSpecialImages release];
	[preview release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization

#define iTetUnnamedThemePlaceholderName			NSLocalizedStringFromTable(@"Unnamed Theme", @"Themes", @"Placeholder name for themes loaded from a file that does not specify a name for the theme")
#define iTetUnknownThemeAuthorPlaceholderName	NSLocalizedStringFromTable(@"Unknown", @"Themes", @"Placeholder for a theme loaded from a file that does not specify the theme's author")
#define iTetBlankThemeDescriptionPlaceholder	NSLocalizedStringFromTable(@"No description provided.", @"Themes", @"Placeholder for a theme loaded from a file that does not provide a description of the theme")

NSString* const iTetThemeFileImageNameSectionIdentifier =	@"blocks=";
NSString* const iTetThemeFileBlockSizeSectionIdentifier =	@"blocksize=";
NSString* const iTetThemeFileNameSectionIdentifier =		@"name=";
NSString* const iTetThemeFileAuthorSectionIdentifier =		@"author=";
NSString* const iTetThemeFileDescriptionSectionIdentifier =	@"description=";

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
	NSString* imageName = [self sectionOfThemeFile:themeFile
									withIdentifier:iTetThemeFileImageNameSectionIdentifier];
	if (imageName == nil)
		return NO;
	
	// Create the image path
	imageFilePath = [[themeFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:imageName];
	
	// Check that the image path is valid
	if (![[NSFileManager defaultManager] fileExistsAtPath:imageFilePath])
		return NO;
	
	[imageFilePath retain];
	
	// Search for the other data in the theme file
	// Cell size
	NSString* cellSizeString = [self sectionOfThemeFile:themeFile
										withIdentifier:iTetThemeFileBlockSizeSectionIdentifier];
	if (cellSizeString != nil)
	{
		CGFloat cell = [cellSizeString floatValue];
		cellSize = NSMakeSize(cell, cell);
	}
	else
	{
		cellSize = NSMakeSize(ITET_DEF_CELL_WIDTH, ITET_DEF_CELL_HEIGHT);
	}
	
	// Name
	themeName = [[self sectionOfThemeFile:themeFile
						   withIdentifier:iTetThemeFileNameSectionIdentifier] retain];
	if (themeName == nil)
		themeName = [[NSString alloc] initWithString:iTetUnnamedThemePlaceholderName];
	
	// Author
	themeAuthor = [[self sectionOfThemeFile:themeFile
							 withIdentifier:iTetThemeFileAuthorSectionIdentifier] retain];
	if (themeAuthor == nil)
		themeAuthor = [[NSString alloc] initWithString:iTetUnknownThemeAuthorPlaceholderName];
	
	// Description
	themeDescription = [[self sectionOfThemeFile:themeFile
								  withIdentifier:iTetThemeFileDescriptionSectionIdentifier] retain];
	if (themeDescription == nil)
		themeDescription = [[NSString alloc] initWithString:iTetBlankThemeDescriptionPlaceholder];
	
	return YES;
}

- (NSString*)sectionOfThemeFile:(NSString*)themeFile
				 withIdentifier:(NSString*)sectionName
{
	// Locate the section heading
	NSRange searchResult;
	searchResult = [themeFile rangeOfString:sectionName
									options:NSCaseInsensitiveSearch];
	
	// If no section with that identifier can be found, abort
	if (searchResult.location == NSNotFound)
		return nil;
	
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
		return nil;
	
	// Return the information found in the specified section
	return [themeFile substringWithRange:dataRange];
}

#define ITET_REMOTE_FIELD_SCALE	0.5

- (void)loadImages
{
	NSImage* sheet = [[[NSImage alloc] initWithContentsOfFile:[self imageFilePath]] autorelease];
	
	// Create an image for the background for the local player's field
	NSRect srcRect = NSMakeRect(0, 0, (cellSize.width * ITET_FIELD_WIDTH), (cellSize.height * ITET_FIELD_HEIGHT));
	NSRect dstRect = srcRect;
	localFieldBackground = [[NSImage alloc] initWithSize:dstRect.size];
	
	// Copy the local player's background to the new image
	[localFieldBackground lockFocus];
	[sheet drawInRect:dstRect
			 fromRect:srcRect
			operation:NSCompositeCopy
			 fraction:1.0];
	[localFieldBackground unlockFocus];
	
	// Create an image for the background for the remote players' fields
	srcRect.origin.x = srcRect.size.width;
	srcRect.origin.y = (srcRect.size.height * (1.0 - ITET_REMOTE_FIELD_SCALE));
	srcRect.size.width *= ITET_REMOTE_FIELD_SCALE;
	srcRect.size.height *= ITET_REMOTE_FIELD_SCALE;
	dstRect.size = srcRect.size;
	remoteFieldBackground = [[NSImage alloc] initWithSize:dstRect.size];
	
	// Copy the remote players' background to the new image
	[remoteFieldBackground lockFocus];
	[sheet drawInRect:dstRect
			 fromRect:srcRect
			operation:NSCompositeCopy
			 fraction:1.0];
	[remoteFieldBackground unlockFocus];
	
	// Clip the full-size cell and special images out of the sheet
	srcRect.origin.x = 0;
	srcRect.origin.y = ([sheet size].height - cellSize.height);
	srcRect.size = cellSize;
	NSArray* cells = [self cellImagesClippedFromSheet:sheet
									beginningWithRect:srcRect];
	
	// Fill the cell and special lists with the images clipped from the sheet
	localCellImages = [[NSArray alloc] initWithArray:[cells subarrayWithRange:NSMakeRange(0, ITET_NUM_CELL_COLORS)]];
	localSpecialImages = [[NSArray alloc] initWithArray:[cells subarrayWithRange:NSMakeRange(ITET_NUM_CELL_COLORS, ITET_NUM_SPECIAL_TYPES)]];
}

- (NSArray*)cellImagesClippedFromSheet:(NSImage*)sheet
					 beginningWithRect:(NSRect)srcRect
{
	// Create a mutable collection of cells
	NSMutableArray* cells = [NSMutableArray arrayWithCapacity:(ITET_NUM_CELL_COLORS + ITET_NUM_SPECIAL_TYPES)];
	NSRect dstRect = NSMakeRect(0, 0, srcRect.size.width, srcRect.size.height);
	
	// Slide the source rect over the row of cell images, copying each one
	for (NSInteger cellNum = 0; cellNum < (ITET_NUM_CELL_COLORS + ITET_NUM_SPECIAL_TYPES); cellNum++)
	{
		// Create a new cell image
		NSImage* cellImage = [[[NSImage alloc] initWithSize:srcRect.size] autorelease];
		
		// Draw the section of the sheet under the source rect to the new image
		[cellImage lockFocus];
		[sheet drawInRect:dstRect
				 fromRect:srcRect
				operation:NSCompositeCopy
				 fraction:1.0];
		[cellImage unlockFocus];
		
		// Add the image to the list of cell images
		[cells addObject:cellImage];
		
		// Translate the source rect to the next cell
		srcRect.origin.x += srcRect.size.width;
	}
	
	return cells;
}

#define ITET_THEME_PREVIEW_HEIGHT (225)

- (void)createPreview
{
	// Determine the size of the background when scaled to fit the preview
	CGFloat bgRatio = ([localFieldBackground size].width / [localFieldBackground size].height);
	NSSize bgSize = NSMakeSize((ITET_THEME_PREVIEW_HEIGHT * bgRatio), ITET_THEME_PREVIEW_HEIGHT);
	
	// Determine the full size of the preview
	NSSize previewSize = NSMakeSize(((ITET_DEF_CELL_WIDTH * 2) + bgSize.width), bgSize.height);
	
	// Release the old preview image (if it exists)
	[preview release];
	
	// Create a new preview image
	preview = [[NSImage alloc] initWithSize:previewSize];
	[preview lockFocus];
	
	// Draw the cell images
	NSRect targetRect = NSMakeRect(0, 0, ITET_DEF_CELL_WIDTH, ITET_DEF_CELL_HEIGHT);
	NSInteger cellNum;
	for (cellNum = 0; cellNum < ITET_NUM_CELL_COLORS; cellNum++)
	{
		targetRect.origin.y = previewSize.height - ((cellNum + 1) * ITET_DEF_CELL_HEIGHT);
		[[localCellImages objectAtIndex:cellNum] drawInRect:targetRect
											  fromRect:NSZeroRect
											 operation:NSCompositeCopy
											  fraction:1.0];
	}
	
	// Draw the specials
	targetRect.origin.x = ITET_DEF_CELL_WIDTH;
	for (cellNum = 0; cellNum < ITET_NUM_SPECIAL_TYPES; cellNum++)
	{
		targetRect.origin.y = previewSize.height - ((cellNum + 1) * ITET_DEF_CELL_HEIGHT);
		[[localSpecialImages objectAtIndex:cellNum] drawInRect:targetRect
												 fromRect:NSZeroRect
												operation:NSCompositeCopy
												 fraction:1.0];
	}
	
	// Draw the background (scaled to fit)
	targetRect.size = bgSize;
	targetRect.origin = NSMakePoint((ITET_DEF_CELL_WIDTH * 2), 0);
	[localFieldBackground drawInRect:targetRect
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

- (void)copyFilesToSupportDirectory
{
	// Get the path to a subdirectory of the Application Support directory to store this theme
	NSError* error = nil;
	NSString* directoryPath = [iTetThemesSupportDirectory pathToSupportDirectoryForTheme:[self themeName]
																	   createIfNecessary:YES
																				   error:&error];
	
	// Check for errors
	if (directoryPath == nil)
		goto abort;
	
	// Create the full paths to the theme and image files
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
	[self setThemeFilePath:themeDestPath];
	[self setImageFilePath:imageDestPath];
	
	// Add theme to cache
	[[iTetTheme themeCache] setObject:self
							   forKey:[self themeFilePath]];
	
abort:;
	if (error != nil)
	{
		// FIXME: present error dialog to user
		NSLog(@"WARNING: unable to copy theme files for theme '%@': %@", [self themeName], error);
	}
}

- (void)removeFilesFromSupportDirectory
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
		// FIXME: present error dialog to user
		NSLog(@"WARNING: attempt to delete theme files for theme '%@' was unsuccessful: %@", [self themeName], error);
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

- (void)setThemeFilePath:(NSString*)themePath
{
	[self willChangeValueForKey:@"themeFilePath"];
	
	// Retain...
	[themePath retain];
	
	// ...Release...
	[themeFilePath release];
	
	// ...Swap
	themeFilePath = [themePath retain];
	
	[self didChangeValueForKey:@"themeFilePath"];
}
@synthesize themeFilePath;

- (void)setImageFilePath:(NSString*)imagePath
{
	[self willChangeValueForKey:@"imageFilePath"];
	
	// Retain...
	[imagePath retain];
	
	// ...Release...
	[imageFilePath release];
	
	// ...Swap
	imageFilePath = [imagePath retain];
	
	[self didChangeValueForKey:@"imageFilePath"];
}
@synthesize imageFilePath;

@synthesize themeName;
@synthesize themeAuthor;
@synthesize themeDescription;

@synthesize localFieldBackground;
@synthesize remoteFieldBackground;

@synthesize cellSize;
- (NSImage*)imageForCellType:(uint8_t)cellType
{
	// Check if the requested cell is a normal cell or a special
	// If the cell is a normal cell, return one of the normal cell images
	if ((cellType > 0) && (cellType <= ITET_NUM_CELL_COLORS))
	{
		return [localCellImages objectAtIndex:(cellType - 1)];
	}
	
	// If the cell is a special, return the image for that special type
	iTetSpecial* cellAsSpecial = [iTetSpecial specialFromCellValue:cellType];
	if ([cellAsSpecial type] != invalidSpecial)
		return [localSpecialImages objectAtIndex:([cellAsSpecial indexNumber] - 1)];
	
	// Invalid cell type
	NSString* excDesc = [NSString stringWithFormat:@"image requested for invalid cell type: %d", cellType];
	NSException* cellTypeException = [NSException exceptionWithName:@"iTetInvalidCellTypeException"
															 reason:excDesc
														   userInfo:nil];
	@throw cellTypeException;
}

@synthesize preview;

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@: %@", [super description], themeName];
}

@end
