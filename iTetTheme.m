//
//  iTetTheme.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//

#import "iTetTheme.h"
#import "iTetField.h"
#import "iTetBlock.h"
#import "iTetSpecials.h"

@implementation iTetTheme

+ (NSArray*)defaultThemeList
{
	return [NSArray arrayWithObjects:
			[self defaultTheme],
			[self themeFromThemeFile:[[NSBundle mainBundle] pathForResource:@"theme_white"
																	 ofType:@"cfg"]],
			[self themeFromThemeFile:[[NSBundle mainBundle] pathForResource:@"theme_mono"
																	 ofType:@"cfg"]],
			[self themeFromThemeFile:[[NSBundle mainBundle] pathForResource:@"GTetrinetTheme"
																	 ofType:@"cfg"]],
			nil];
}

+ (id)defaultTheme
{
	return [[[self alloc] init] autorelease];
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
		return nil;
	
	// Load and clip the images from the sheet
	[self loadImages];
	
	// Create the preview image
	[self createPreview];
	
	return self;
}

- (id)init
{	
	// Read the theme data from the default theme file
	return [self initWithThemeFile:[[[NSBundle mainBundle] pathForResource:@"theme"
																	ofType:@"cfg"] retain]];
}

- (void)dealloc
{
	[themeFilePath release];
	[imageFilePath release];
	
	[name release];
	[author release];
	[description release];
	
	[background release];
	[cellImages release];
	[specialImages release];
	[preview release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization

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
		name = [[themeFile substringWithRange:dataRange] retain];
	else
		name = [[NSString alloc] initWithString:@"Unnamed Theme"];
	
	// Author
	dataRange = [self rangeOfSection:@"author="
						 inThemeFile:themeFile];
	if (dataRange.location != NSNotFound)
		author = [[themeFile substringWithRange:dataRange] retain];
	else
		author = [[NSString alloc] initWithString:@"Unknown"];
	
	// Description
	dataRange = [self rangeOfSection:@"description="
						 inThemeFile:themeFile];
	if (dataRange.location != NSNotFound)
		description = [[themeFile substringWithRange:dataRange] retain];
	else
		description = [[NSString alloc] initWithString:@"No description provided."];
	
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
	dataRange.location = searchResult.location + searchResult.length;
	dataRange.length = [themeFile length] - dataRange.location;
	searchResult = [themeFile rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
											  options:0
												range:dataRange];
	
	// If a newline was found, the section ends there; otherwise, the section
	// is assumed to end at the end of the file
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
	[cellImages release];
	cellImages = [[NSArray alloc] initWithArray:
				  [cells subarrayWithRange:NSMakeRange(0, ITET_NUM_CELL_COLORS)]];
	[specialImages release];
	specialImages = [[NSArray alloc] initWithArray:
					 [cells subarrayWithRange:NSMakeRange(ITET_NUM_CELL_COLORS, ITET_NUM_SPECIAL_TYPES)]];
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
	// Attempt to create the theme from the file at the encoded path
	return [self initWithThemeFile:[decoder decodeObjectForKey:iTetThemeFilePathKey]];
}

#pragma mark -
#pragma mark Comparators (uses name)

- (BOOL)isEqual:(id)other
{
	if ([other isMemberOfClass:[self class]])
	{
		iTetTheme* otherTheme = (iTetTheme*)other;
		
		if ([otherTheme hash] == [self hash])
			return YES;
	}
	
	return NO;
}

- (NSUInteger)hash
{
	return [name hash];
}

#pragma mark -
#pragma mark Accessors

@synthesize themeFilePath;
@synthesize imageFilePath;

@synthesize name;
@synthesize author;
@synthesize description;

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
	uint8_t num = iTetSpecialNumberFromType((iTetSpecialType)cellType);
	if (num > 0)
		return [specialImages objectAtIndex:(num - 1)];
	
	// Invalid cell type
	NSLog(@"Warning: Image requested for invalid cell type: %d", cellType);
	return nil;
}


@synthesize preview;

@end
