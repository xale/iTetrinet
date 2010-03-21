//
//  iTetTextAttributes.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetTextAttributes.h"
#import "NSColor+Comparisons.h"

#define iTetSilverTextColor		[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]
#define iTetGreenTextColor		[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0]
#define iTetOliveTextColor		[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.0 alpha:1.0]
#define iTetTealTextColor		[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.5 alpha:1.0]
#define iTetDarkBlueTextColor	[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.5 alpha:1.0]
#define iTetMaroonTextColor		[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0]

NSCharacterSet* iTetTextAttributeCharacterSet = nil;

@interface iTetTextAttributes (Private)

+ (NSString*)textAttributeCharactersString;

@end

@implementation iTetTextAttributes

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

+ (NSDictionary*)defaultTextAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[self defaultTextColor], NSForegroundColorAttributeName,
			[self plainTextFont], NSFontAttributeName,
			[NSNumber numberWithInt:NSUnderlineStyleNone], NSUnderlineStyleAttributeName,
			nil];
}

#pragma mark -
#pragma mark Attribute/Code Conversions

+ (NSDictionary*)textAttributeForCode:(uint8_t)attributeCode
{
	// Check if the code represents a color
	NSColor* color = [self textColorForCode:attributeCode];
	if (color != nil)
	{
		return [NSDictionary dictionaryWithObject:color
										   forKey:NSForegroundColorAttributeName];
	}
	
	// Determine what the code represents
	switch (attributeCode)
	{
		case boldText:
			return [NSDictionary dictionaryWithObject:[self boldTextFont]
											   forKey:NSFontAttributeName];
		case italicText:
			return [NSDictionary dictionaryWithObject:[self italicTextFont]
											   forKey:NSFontAttributeName];
		case underlineText:
			return [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(NSUnderlineStyleSingle | NSUnderlinePatternSolid)]
											   forKey:NSUnderlineStyleAttributeName];
	}
	
	NSLog(@"WARNING: invalid attribute code in iTetTextAttributes +textAttributeForCode: '%d'", attributeCode);
	
	return nil;
}

#pragma mark -
#pragma mark Colors

+ (NSColor*)defaultTextColor
{
	return [NSColor blackColor];
}

+ (NSColor*)textColorForCode:(uint8_t)attributeCode
{
	switch (attributeCode)
	{
		case blackTextColor:
			return [NSColor blackColor];
			
		case whiteTextColor:
			return [NSColor whiteColor];
			
		case grayTextColor:
			return [NSColor grayColor];
			
		case silverTextColor:
			return iTetSilverTextColor;
			
		case redTextColor:
			return [NSColor redColor];
			
		case yellowTextColor:
			return [NSColor yellowColor];
			
		case limeTextColor:
			return [NSColor greenColor];
			
		case greenTextColor:
			return iTetGreenTextColor;
			
		case oliveTextColor:
			return iTetOliveTextColor;
			
		case tealTextColor:
			return iTetTealTextColor;
			
		case cyanTextColor:
			return [NSColor cyanColor];
			
		case blueTextColor:
			return [NSColor blueColor];
			
		case darkBlueTextColor:
			return iTetDarkBlueTextColor;
			
		case purpleTextColor:
			return [NSColor purpleColor];
			
		case maroonTextColor:
			return iTetMaroonTextColor;
			
		case magentaTextColor:
			return [NSColor magentaColor];
			
		default:
			break;
	}
	
	return nil;
}

+ (iTetTextColorAttribute)codeForTextColor:(NSColor*)color
{
	if ([color hasSameRGBValuesAsColor:[NSColor blackColor]])
		return blackTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor whiteColor]])
		return whiteTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor grayColor]])
		return grayTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetSilverTextColor])
		return silverTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor redColor]])
		return redTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor yellowColor]])
		return yellowTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor greenColor]])
		return limeTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetGreenTextColor])
		return greenTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetOliveTextColor])
		return oliveTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetTealTextColor])
		return tealTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor cyanColor]])
		return cyanTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor blueColor]])
		return blueTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetDarkBlueTextColor])
		return darkBlueTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor purpleColor]])
		return purpleTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetMaroonTextColor])
		return maroonTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor magentaColor]])
		return magentaTextColor;
	
	return noColor;
}

#pragma mark -
#pragma mark Fonts

+ (NSFont*)fontWithTraits:(NSFontTraitMask)fontTraits
{
	if (fontTraits & NSBoldFontMask)
	{
		if (fontTraits & NSItalicFontMask)
			return [self boldItalicTextFont];
		
		return [self boldTextFont];
	}
	
	if (fontTraits & NSItalicFontMask)
		return [self italicTextFont];
	
	return [self plainTextFont];
}

+ (NSFont*)plainTextFont
{
	return [NSFont fontWithName:@"Helvetica"
						   size:12.0];
}

+ (NSFont*)boldTextFont
{
	return [[NSFontManager sharedFontManager] convertFont:[self plainTextFont]
											  toHaveTrait:NSBoldFontMask];
}

+ (NSFont*)italicTextFont
{
	return [[NSFontManager sharedFontManager] convertFont:[self plainTextFont]
											  toHaveTrait:NSItalicFontMask];
}

+ (NSFont*)boldItalicTextFont
{
	return [[NSFontManager sharedFontManager] convertFont:[self plainTextFont]
											  toHaveTrait:(NSBoldFontMask | NSItalicFontMask)];
}

#pragma mark -
#pragma mark Text Attribute Character Set

+ (NSCharacterSet*)textAttributeCharacterSet
{
	@synchronized(self)
	{
		if (iTetTextAttributeCharacterSet == nil)
		{
			iTetTextAttributeCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:[self textAttributeCharactersString]] retain];
		}
	}
	
	return iTetTextAttributeCharacterSet;
}

+ (NSString*)textAttributeCharactersString
{
	NSMutableString* attributeChars = [NSMutableString string];
	
	for (char c = 0; c < ITET_HIGHEST_ATTR_CODE; c++)
	{
		switch (c)
		{
			case blackTextColor:
			case whiteTextColor:
			case grayTextColor:
			case silverTextColor:
			case redTextColor:
			case yellowTextColor:
			case limeTextColor:
			case greenTextColor:
			case oliveTextColor:
			case tealTextColor:
			case cyanTextColor:
			case blueTextColor:
			case darkBlueTextColor:
			case purpleTextColor:
			case maroonTextColor:
			case magentaTextColor:
			case italicText:
			case underlineText:
			case boldText:
				[attributeChars appendFormat:@"%c", c];
				break;
			
			case noColor:
				break;
		}
	}
	
	return [NSString stringWithString:attributeChars];
}

@end
