//
//  iTetTextAttributes.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	noColor =			0,
	blackTextColor =	4,
	whiteTextColor =	24,
	grayTextColor =		6,
	silverTextColor =	15,
	redTextColor =		20,
	yellowTextColor =	25,
	limeTextColor =		14,
	greenTextColor =	12,
	oliveTextColor =	18,
	tealTextColor =		23,
	cyanTextColor =		3,
	blueTextColor =		5,
	darkBlueTextColor =	17,
	purpleTextColor =	19,
	maroonTextColor =	16,
	magentaTextColor =	8
} iTetTextColorAttribute;

typedef enum
{
	italicText =		22,
	underlineText =		31,
	boldText =			2
} iTetTextFontAttribute;

#define ITET_HIGHEST_ATTR_CODE	31

@interface iTetTextAttributes : NSObject

// Returns an NSCharacterSet containing all characters used as formatting data in the TetriNET protocol
+ (NSCharacterSet*)textAttributeCharacterSet;

// Returns a dictionary containing the default text attributes
+ (NSDictionary*)defaultTextAttributes;

// Returns the text attribute corresponding to the specified attribute code
+ (NSDictionary*)textAttributeForCode:(uint8_t)attributeCode;

// Returns the foreground text color represented by the specified color code
+ (NSColor*)textColorForCode:(uint8_t)attribute;

// Returns the color code representing the specified foreground text color
+ (iTetTextColorAttribute)codeForTextColor:(NSColor*)color;

// Returns the default foreground text color for the partyline message view
+ (NSColor*)defaultTextColor;

// Returns the fonts used in the partyline message view
+ (NSFont*)fontWithTraits:(NSFontTraitMask)fontTraits;
+ (NSFont*)plainTextFont;
+ (NSFont*)boldTextFont;
+ (NSFont*)italicTextFont;
+ (NSFont*)boldItalicTextFont;

@end

