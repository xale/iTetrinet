//
//  iTetTextAttributesController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/7/10.
//

#import "iTetTextAttributesController.h"
#import "iTetAttributeRangePair.h"
#import "NSMutableData+SingleByte.h"
#import "NSString+ASCIIData.h"

@implementation iTetTextAttributesController

#pragma mark -
#pragma mark Interface Actions

- (IBAction)changeTextColor:(id)sender
{
	NSTextView* editor = (NSTextView*)[partylineMessageField currentEditor];
	
	// Determine the text color to use
	NSColor* textColor = iTetTextColorForAttribute([sender tag]);
	
	// Determine if there is text selected
	NSRange selection = [editor selectedRange];
	if (selection.length > 0)
	{
		// Change the text color of the selection
		[editor setTextColor:textColor
					   range:selection];
	}
	else
	{
		// Set the color of the text being typed
		// Get the current typing attributes
		NSMutableDictionary* attrDict = [[editor typingAttributes] mutableCopy];
		
		// Change the text color
		[attrDict setObject:textColor
					 forKey:NSForegroundColorAttributeName];
		[editor setTypingAttributes:attrDict];
		
		[attrDict release];
	}
}

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Color change actions are available if the message field has keyboard focus
	if ([item action] == @selector(changeTextColor:))
		return ([partylineMessageField currentEditor] != nil);
	
	return YES;
}

#pragma mark -
#pragma mark Message Formatting

NSString* const iTetSameAttributePredicateFormat =		@"attributeType == %d";
NSString* const iTetMultipleAttributesPredicateFormat =	@"(attributeType == %d) OR (attributeType == %d)";

- (NSAttributedString*)formattedMessageFromData:(NSData*)messageData
{
	// Create a mutable attributed string to apply attributes to
	NSString* baseString = [NSString stringWithASCIIData:messageData];
	NSMutableAttributedString* formattedString = [[[NSMutableAttributedString alloc] initWithString:baseString] autorelease];
	
	// Create bold and italic versions of the default chat view font
	NSFont* boldFont = [[NSFontManager sharedFontManager] convertFont:[partylineChatView font]
														  toHaveTrait:(NSBoldFontMask | NSUnitalicFontMask)];
	NSFont* italicFont = [[NSFontManager sharedFontManager] convertFont:[partylineChatView font]
															toHaveTrait:(NSItalicFontMask | NSUnboldFontMask)];
	NSFont* boldItalicFont = [[NSFontManager sharedFontManager] convertFont:[partylineChatView font]
																toHaveTrait:(NSBoldFontMask | NSItalicFontMask)];
	
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
		NSDictionary* attribute = nil;
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
					attribute = [NSDictionary dictionaryWithObject:italicFont
															forKey:NSFontAttributeName];
					byte = italicText;
				}
				else
				{
					// Italic is now closed; create a bold attribute
					attribute = [NSDictionary dictionaryWithObject:boldFont
															forKey:NSFontAttributeName];
					byte = boldText;
				}
				
				// Add the the new tag
				[openAttributes addObject:[iTetAttributeRangePair pairWithAttributeType:byte
																				  value:attribute
																	beginningAtLocation:index]];
			}
			
			// Add this attribute to the string
			[formattedString addAttributes:[attributeAndRange attributeValue]
									 range:[attributeAndRange range]];
			
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
						[formattedString addAttributes:[italicRange attributeValue]
												 range:[italicRange range]];
						
						// Remove italics from the open tags
						[openAttributes removeObject:italicRange];
						
						// Create a new attribute with a bold and italic font
						attribute = [NSDictionary dictionaryWithObject:boldItalicFont
																forKey:NSFontAttributeName];
						byte = boldItalicText;
					}
					else
					{
						// If there are no open italic tags, just create a new bold attribute
						attribute = [NSDictionary dictionaryWithObject:boldFont
																forKey:NSFontAttributeName];
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
						attribute = [NSDictionary dictionaryWithObject:boldItalicFont
																forKey:NSFontAttributeName];
						byte = boldItalicText;
					}
					else
					{
						// If there are no open bold tags, just create a new italic attribute
						attribute = [NSDictionary dictionaryWithObject:italicFont
																forKey:NSFontAttributeName];
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
					NSColor* textColor = iTetTextColorForAttribute((iTetTextColorAttribute)byte);
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

- (NSData*)dataFromFormattedMessage:(NSAttributedString*)message
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
		color = iTetAttributeForTextColor([attributes objectForKey:NSForegroundColorAttributeName]);
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
