//
//  NSAttributedString+TetrinetTextAttributes.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/20/10.
//

#import "NSAttributedString+TetrinetTextAttributes.h"
#import "iTetTextAttributes.h"
#import "NSString+MessageData.h"
#import "NSColor+Comparisons.h"

@implementation NSAttributedString (TetrinetTextAttributes)

+ (id)attributedStringWithString:(NSString*)string
{
	return [[[self alloc] initWithString:string] autorelease];
}

- (id)initWithPlineMessageData:(NSData*)messageData
{
	// Convert the message to a raw string
	NSString* rawMessage = [NSString stringWithMessageData:messageData];
	
	// Split the message on formatting characters
	NSArray* messageTokens = [rawMessage componentsSeparatedByCharactersInSet:[iTetTextAttributes chatTextAttributeCharacterSet]];
	
	// Recombine the message tokens (dropping the formatting characters) and store in an NSMutableAttributedString with no attributes
	NSMutableAttributedString* formattedMessage = [NSMutableAttributedString attributedStringWithString:[messageTokens componentsJoinedByString:@""]];
	
	// If the message is blank, return an empty attributed string
	if ([formattedMessage length] == 0)
		return [self init];
	
	// Maintain a dictionary of open attributes
	NSMutableDictionary* openAttributes = [NSMutableDictionary dictionaryWithDictionary:[iTetTextAttributes defaultChatTextAttributes]];
	
	// Scan the message data for formatting bytes
	NSUInteger characterIndex = -1, lastAttributeIndex = 0, charactersRemoved = 0;
	for (NSUInteger tokenNumber = 0; tokenNumber < [messageTokens count]; tokenNumber++)
	{
		// Find index of the next formatting character
		characterIndex += [[messageTokens objectAtIndex:tokenNumber] length] + 1;
		
		// Check that we're still within the bounds of the message
		if (characterIndex >= [rawMessage length])
			break;
		
		// Determine the attribute specified by the formatting character
		NSDictionary* newAttribute = [iTetTextAttributes chatTextAttributeForCode:[rawMessage characterAtIndex:characterIndex]];
		
		// Apply the existing attributes to the message
		if ((characterIndex - charactersRemoved) > lastAttributeIndex)
		{
			[formattedMessage addAttributes:openAttributes
									  range:NSMakeRange(lastAttributeIndex, ((characterIndex - charactersRemoved) - lastAttributeIndex))];
			lastAttributeIndex = (characterIndex - charactersRemoved);
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
		charactersRemoved++;
	}
	
	// Apply any final attributes
	if ((characterIndex - charactersRemoved) > lastAttributeIndex)
	{
		[formattedMessage addAttributes:openAttributes
								  range:NSMakeRange(lastAttributeIndex, ((characterIndex - charactersRemoved) - lastAttributeIndex))];
	}
	
	// Return the finished attributed message
	return [self initWithAttributedString:formattedMessage];
}

- (NSData*)plineMessageData
{
	// Create the raw-data ASCII version of the message
	NSMutableString* formattedMessage = [NSMutableString stringWithString:[self string]];
	NSUInteger charactersAdded = 0;
	
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
			[formattedMessage insertString:[NSString stringWithFormat:@"%c", color]
								   atIndex:(attrRange.location + charactersAdded)];
			charactersAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithChar:color]];
		}
		
		// Underline
		if ([[attributes objectForKey:NSUnderlineStyleAttributeName] intValue] != NSUnderlineStyleNone)
		{
			// Add underline code to message
			// Open tag
			[formattedMessage insertString:[NSString stringWithFormat:@"%c", underlineText]
								   atIndex:(attrRange.location + charactersAdded)];
			charactersAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithChar:underlineText]];
		}
		
		// Font traits (bold, italic)
		NSFontTraitMask fontTraits = [[NSFontManager sharedFontManager] traitsOfFont:[attributes objectForKey:NSFontAttributeName]];
		if (fontTraits & NSBoldFontMask)
		{
			// Add bold code to message
			// Open tag
			[formattedMessage insertString:[NSString stringWithFormat:@"%c", boldText]
								   atIndex:(attrRange.location + charactersAdded)];
			charactersAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithChar:boldText]];
		}
		if (fontTraits & NSItalicFontMask)
		{
			// Add italics code to message
			// Open tag
			[formattedMessage insertString:[NSString stringWithFormat:@"%c", italicText]
								   atIndex:(attrRange.location + charactersAdded)];
			charactersAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithChar:italicText]];
		}
		
		// Close all open tags (in reverse order) before moving to next attribute range
		for (NSNumber* tag in [openTags reverseObjectEnumerator])
		{
			// Close the tag
			[formattedMessage insertString:[NSString stringWithFormat:@"%c", [tag charValue]]
								   atIndex:(attrRange.location + attrRange.length + charactersAdded)];
			charactersAdded++;
		}
		
		// Clear the list of open tags
		openTags = [NSMutableArray array];
		
		// Advance the index to the end of this attribute range
		index = (attrRange.location + attrRange.length);
	}
	
	// Return the formatted message as an NSData object
	return [formattedMessage messageData];
}

@end
