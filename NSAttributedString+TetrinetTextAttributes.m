//
//  NSAttributedString+TetrinetTextAttributes.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/20/10.
//

#import "NSAttributedString+TetrinetTextAttributes.h"
#import "iTetTextAttributes.h"
#import "NSString+ASCIIData.h"
#import "NSData+SingleByte.h"
#import "NSColor+Comparisons.h"

@implementation NSAttributedString (TetrinetTextAttributes)

+ (id)attributedStringWithString:(NSString*)string
{
	return [[[self alloc] initWithString:string] autorelease];
}

- (id)initWithPlineMessageData:(NSData*)messageData
{
	// Convert the message to a string, and split on formatting characters
	NSArray* messageTokens = [[NSString stringWithASCIIData:messageData] componentsSeparatedByCharactersInSet:[iTetTextAttributes chatTextAttributeCharacterSet]];
	
	// Recombine the message tokens (stripping the formatting characters) and store in an NSMutableAttributedString with no attributes
	NSMutableAttributedString* formattedMessage = [NSMutableAttributedString attributedStringWithString:[messageTokens componentsJoinedByString:@""]];
	
	// If the message is blank, return an empty attributed string
	if ([formattedMessage length] == 0)
		return [self init];
	
	// Maintain a dictionary of open attributes
	NSMutableDictionary* openAttributes = [NSMutableDictionary dictionaryWithDictionary:[iTetTextAttributes defaultChatTextAttributes]];
	
	// Scan the message data for formatting bytes
	const uint8_t* rawData = (uint8_t*)[messageData bytes];
	NSUInteger byteIndex = -1, lastAttributeIndex = 0, bytesRemoved = 0;
	for (NSUInteger tokenNumber = 0; tokenNumber < [messageTokens count]; tokenNumber++)
	{
		// Find index of the next formatting character
		byteIndex += [[messageTokens objectAtIndex:tokenNumber] length] + 1;
		
		// Check if we're still within the bounds of the message data
		if (byteIndex >= [messageData length])
			break;
		
		// Determine the attribute specified by the formatting character
		NSDictionary* newAttribute = [iTetTextAttributes chatTextAttributeForCode:rawData[byteIndex]];
		
		// Apply the existing attributes to the message
		if ((byteIndex - bytesRemoved) > lastAttributeIndex)
		{
			[formattedMessage addAttributes:openAttributes
									  range:NSMakeRange(lastAttributeIndex, ((byteIndex - bytesRemoved) - lastAttributeIndex))];
			lastAttributeIndex = (byteIndex - bytesRemoved);
		}
		
		// Compare the new value for this attribute with the old
		id attributeKey = [[newAttribute allKeys] objectAtIndex:0];
		
		// Colors: compare RGB values
		if ([attributeKey isEqual:NSForegroundColorAttributeName])
		{
			// If the old color is the same as the new, "close" the color attribute
			NSColor* oldColor = [openAttributes objectForKey:attributeKey];
			NSColor* newColor = [newAttribute objectForKey:attributeKey];
			if ([newColor hasSameRGBValuesAsColor:oldColor])
			{
				// Set the color attribute to the default text color
				[openAttributes setObject:[iTetTextAttributes defaultTextColor]
								   forKey:attributeKey];
			}
			else
			{
				// Set the color attribute to the new color
				[openAttributes setObject:newColor
								   forKey:attributeKey];
			}
		}
		// Font: xor font traits
		else if ([attributeKey isEqual:NSFontAttributeName])
		{
			NSFontTraitMask oldFontTraits = [[NSFontManager sharedFontManager] traitsOfFont:[openAttributes objectForKey:attributeKey]];
			NSFontTraitMask changedFontTrait = [[NSFontManager sharedFontManager] traitsOfFont:[newAttribute objectForKey:attributeKey]];
			
			[openAttributes setObject:[iTetTextAttributes chatTextFontWithTraits:(oldFontTraits ^ changedFontTrait)]
							   forKey:NSFontAttributeName];
		}
		// Underline: toggle between on and off
		else if ([attributeKey isEqual:NSUnderlineStyleAttributeName])
		{
			NSInteger underlineStyle = [[openAttributes objectForKey:attributeKey] integerValue];
			
			// Toggle the underline on or off
			if (underlineStyle & NSUnderlineStyleSingle)
				underlineStyle = NSUnderlineStyleNone;
			else
				underlineStyle = (NSUnderlineStyleSingle | NSUnderlinePatternSolid);
			
			[openAttributes setObject:[NSNumber numberWithInteger:underlineStyle]
							   forKey:attributeKey];
		}
		else
			NSLog(@"WARNING: unknown attribute key in NSAttributedString -initWithPlineMessageData: '%@'", attributeKey);
		
		// Increment the number of formatting bytes removed from the final message
		bytesRemoved++;
	}
	
	// Apply any final attributes
	if ((byteIndex - bytesRemoved) > lastAttributeIndex)
	{
		[formattedMessage addAttributes:openAttributes
								  range:NSMakeRange(lastAttributeIndex, ((byteIndex - bytesRemoved) - lastAttributeIndex))];
	}
	
	// Return the finished attributed message
	return [self initWithAttributedString:formattedMessage];
}

- (NSData*)plineMessageData
{
	// Create the raw-data ASCII version of the message
	NSMutableData* messageData = [NSMutableData dataWithData:[[self string] dataUsingEncoding:NSASCIIStringEncoding
																		 allowLossyConversion:YES]];
	NSUInteger bytesAdded = 0;
	
	// Search the messages for attributes
	NSMutableArray* openTags = [NSMutableArray array];
	NSRange fullRange = NSMakeRange(0, [self length]);
	for (NSUInteger index = 0; index < [self length]; )
	{
		// Find the attributes and their extent at this point in the message
		NSRange attrRange;
		NSDictionary* attributes = [self attributesAtIndex:index
									 longestEffectiveRange:&attrRange
												   inRange:fullRange];
		
		// Check for specific attributes that interest us
		// Text color
		iTetTextColorAttribute color = [iTetTextAttributes codeForChatTextColor:[attributes objectForKey:NSForegroundColorAttributeName]];
		if ((color != noColor) && (color != blackTextColor))
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
		
		// Font traits (bold, italic)
		NSFontTraitMask fontTraits = [[NSFontManager sharedFontManager] traitsOfFont:[attributes objectForKey:NSFontAttributeName]];
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
