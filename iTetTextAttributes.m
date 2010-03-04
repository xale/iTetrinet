//
//  iTetTextAttributes.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetTextAttributes.h"
#import "NSColor+Comparisons.h"
#import "NSString+ASCIIData.h"
#import "NSMutableData+SingleByte.h"
#import "iTetAttributeRangePair.h"

#define iTetSilverTextColor		[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]
#define iTetGreenTextColor		[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0]
#define iTetOliveTextColor		[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.0 alpha:1.0]
#define iTetTealTextColor		[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.5 alpha:1.0]
#define iTetDarkBlueTextColor	[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.5 alpha:1.0]
#define iTetMaroonTextColor		[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0]

@implementation iTetTextAttributes

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

#pragma mark -
#pragma mark Color/Code Conversions

+ (NSColor*)textColorForAttribute:(iTetTextColorAttribute)attribute
{
	switch (attribute)
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

+ (iTetTextColorAttribute)attributeForTextColor:(NSColor*)color
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
#pragma mark Message Formatting

NSString* const iTetSameAttributePredicateFormat =		@"attributeType == %d";
NSString* const iTetMultipleAttributesPredicateFormat =	@"(attributeType == %d) OR (attributeType == %d)";

+ (NSAttributedString*)formattedMessageFromData:(NSData*)messageData
{
	// Create a mutable attributed string to apply attributes to
	NSString* baseString = [NSString stringWithASCIIData:messageData];
	NSMutableAttributedString* formattedString = [[[NSMutableAttributedString alloc] initWithString:baseString] autorelease];
	
	// Scan the message for formatting information
	const uint8_t* rawData = (uint8_t*)[messageData bytes];
	NSMutableArray* openAttributes = [NSMutableArray array];
	for (NSUInteger index = 0; index < [messageData length]; index++)
	{
		// Check if this byte is a non-printing character
		uint8_t byte = rawData[index];
		if (byte > ITET_HIGHEST_ATTR_CODE)
			continue;
		
		// Check if a matching attribute tag is already open
		NSArray* filteredArray;
		id attribute = nil;
		if (byte == boldText)
		{
			// Search for "bold" or "bold and italic" tags
			filteredArray = [openAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:iTetMultipleAttributesPredicateFormat, boldText, boldItalicText]];
		}
		else if (byte == italicText)
		{
			// Search for "italic" or "bold and italic" tags
			filteredArray = [openAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:iTetMultipleAttributesPredicateFormat, italicText, boldItalicText]];
		}
		else
		{
			// Search for the same tag
			filteredArray = [openAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:iTetSameAttributePredicateFormat, byte]];
		}
		
		// If a matching tag was found, close the tag and apply the attribute
		if ([filteredArray count] > 0)
		{
			// "Close" the range of this attribute at the character before this one
			iTetAttributeRangePair* attributeAndRange = [filteredArray objectAtIndex:0];
			[attributeAndRange setLastIndexInRange:(index - 1)];
			
			// Check if this a "bold and italic" tag
			if ([attributeAndRange attributeType].fontAttribute == boldItalicText)
			{
				// Create and open a tag for the remaining attribute
				if (byte == boldText)
				{
					// Bold is now closed; create an italic attribute
					attribute = [NSNumber numberWithInt:NSItalicFontMask];
					byte = italicText;
				}
				else
				{
					// Italic is now closed; create a bold attribute
					attribute = [NSNumber numberWithInt:NSBoldFontMask];
					byte = boldText;
				}
				
				// Add the the new tag
				[openAttributes addObject:[iTetAttributeRangePair pairWithAttributeType:byte
																				  value:attribute
																	beginningAtLocation:index]];
			}
			
			// Add this attribute to the string
			if ([[attributeAndRange attributeValue] isKindOfClass:[NSDictionary class]])
			{
				[formattedString addAttributes:[attributeAndRange attributeValue]
										 range:[attributeAndRange range]];
			}
			else if ([[attributeAndRange attributeValue] isKindOfClass:[NSNumber class]])
			{
				[formattedString applyFontTraits:[[attributeAndRange attributeValue] intValue]
										   range:[attributeAndRange range]];
			}
			
			// Remove from the list of open attributes
			[openAttributes removeObject:attributeAndRange];
		}
		else
		{
			// Otherwise, determine if this character maps to a text attribute
			switch (byte)
			{
				case boldText:
				{
					// Bold
					// Check if there is an open italic tag
					NSArray* italicTags = [openAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:iTetSameAttributePredicateFormat, italicText]];
					if ([italicTags count] > 0)
					{
						// Close the italics tag
						iTetAttributeRangePair* italicRange = [italicTags objectAtIndex:0];
						[italicRange setLastIndexInRange:(index - 1)];
						
						// Apply italics to the region between the italics and bold tags
						[formattedString applyFontTraits:[[italicRange attributeValue] intValue]
												   range:[italicRange range]];
						
						// Remove italics from the open tags
						[openAttributes removeObject:italicRange];
						
						// Create a new attribute with a bold and italic font
						attribute = [NSNumber numberWithInt:(NSBoldFontMask | NSItalicFontMask)];
						byte = boldItalicText;
					}
					else
					{
						// If there are no open italic tags, just create a new bold attribute
						attribute = [NSNumber numberWithInt:NSBoldFontMask];
					}
					break;
				}
					
				case italicText:
				{
					// Italic
					// Check if there is an open bold tag
					NSArray* boldTags = [openAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:iTetSameAttributePredicateFormat, boldText]];
					if ([boldTags count] > 0)
					{
						// Close the bold tag
						iTetAttributeRangePair* boldRange = [boldTags objectAtIndex:0];
						[boldRange setLastIndexInRange:(index - 1)];
						
						// Apply bold to the range between the bold and italic tags
						[formattedString addAttributes:[boldRange attributeValue]
												 range:[boldRange range]];
						
						// Remove bold from the open tags
						[openAttributes removeObject:boldRange];
						
						// Create a new attribute with a bold and italic font
						attribute = [NSNumber numberWithInt:(NSBoldFontMask | NSItalicFontMask)];
						byte = boldItalicText;
					}
					else
					{
						// If there are no open bold tags, just create a new italic attribute
						attribute = [NSNumber numberWithInt:NSItalicFontMask];
					}
					break;
				}
					
				case underlineText:
					// Underline
					attribute = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(NSUnderlineStyleSingle | NSUnderlinePatternSolid)]
															forKey:NSUnderlineStyleAttributeName];
					break;
					
				default:
				{
					// Colored text
					NSColor* textColor = [self textColorForAttribute:(iTetTextColorAttribute)byte];
					if (textColor != nil)
					{
						attribute = [NSDictionary dictionaryWithObject:textColor
																forKey:NSForegroundColorAttributeName];
					}
					break;
				}
			}
			
			// If this is a valid attribute, add it to the list of open attributes
			if (attribute != nil)
			{
				[openAttributes addObject:[iTetAttributeRangePair pairWithAttributeType:byte
																				  value:attribute
																	beginningAtLocation:index]];
			}
		}
	}
	
	return formattedString;
}

+ (NSData*)dataFromFormattedMessage:(NSAttributedString*)message
				withAttributedRange:(NSRange)rangeWithAttributes
{
	// Create the raw ASCII version of the message
	NSMutableData* messageData = [NSMutableData dataWithData:[[message string] dataUsingEncoding:NSASCIIStringEncoding
																			allowLossyConversion:YES]];
	NSUInteger bytesAdded = 0;
	
	// Search the messages for attributes
	NSUInteger index = rangeWithAttributes.location;
	NSDictionary* attributes;
	NSRange attrRange;
	NSMutableArray* openTags = [NSMutableArray array];
	iTetTextColorAttribute color;
	NSFontTraitMask fontTraits;
	while (index < (rangeWithAttributes.location + rangeWithAttributes.length))
	{
		// Find the attributes and their extent at this point in the message
		attributes = [message attributesAtIndex:index
						  longestEffectiveRange:&attrRange
										inRange:rangeWithAttributes];
		
		// Check for specific attributes that interest us
		// Text color
		color = [self attributeForTextColor:[attributes objectForKey:NSForegroundColorAttributeName]];
		if (color != blackTextColor)
		{
			// Add color codes to the outgoing message data
			// Open tag
			[messageData insertByte:(uint8_t)color
							atIndex:(attrRange.location + bytesAdded)];
			bytesAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithInt:color]];
		}
		
		// Underline
		if ([[attributes objectForKey:NSUnderlineStyleAttributeName] intValue] != NSUnderlineStyleNone)
		{
			// Add underline code to message
			// Open tag
			[messageData insertByte:(uint8_t)underlineText
							atIndex:(attrRange.location + bytesAdded)];
			bytesAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithInt:underlineText]];
		}
		
		fontTraits = [[NSFontManager sharedFontManager] traitsOfFont:[attributes objectForKey:NSFontAttributeName]];
		
		// Bold
		if (fontTraits & NSBoldFontMask)
		{
			// Add bold code to message
			// Open tag
			[messageData insertByte:(uint8_t)boldText
							atIndex:(attrRange.location + bytesAdded)];
			bytesAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithInt:boldText]];
		}
		
		// Italics
		if (fontTraits & NSItalicFontMask)
		{
			// Add italics code to message
			// Open tag
			[messageData insertByte:(uint8_t)italicText
							atIndex:(attrRange.location + bytesAdded)];
			bytesAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithInt:italicText]];
		}
		
		// Close all open tags (in reverse order) before moving to next attribute range
		for (NSNumber* tag in [openTags reverseObjectEnumerator])
		{
			// Close the tag
			[messageData insertByte:(uint8_t)[tag intValue]
							atIndex:(attrRange.location + attrRange.length + bytesAdded)];
			bytesAdded++;
		}
		
		// Clear the list of open tags
		openTags = [NSMutableArray array];
		
		// Advance the index to the end of this attribute range
		index = (attrRange.location + attrRange.length);
	}
	
	// Return the formatted data
	return [NSData dataWithData:messageData];
}

@end
